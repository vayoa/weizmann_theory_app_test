import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';

part 'bank_event.dart';
part 'bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  late final String appDirectory;
  late final String jsonPath;
  late final File jsonFile;
  static const String jsonFilePath = r'WeizmannTheory\bank.json';
  static const String backupFilePath = r'WeizmannTheory\Migration Backups';

  Map<String, Map<String, bool>> _titles = {};

  Map<String, Map<String, bool>> get titles => _titles;

  bool get hasSelected =>
      _packageHasSelected.values.any((selected) => selected ?? true);

  Map<String, bool?> _packageHasSelected = {};

  Map<String, bool?> get packageHasSelected => _packageHasSelected;

  Map<String, List<String>> get selectedTitles {
    Map<String, List<String>> packages = {};
    for (String package in _titles.keys) {
      bool added = false;
      for (String title in _titles[package]!.keys) {
        if (_titles[package]![title]!) {
          if (!added) {
            packages[package] = [];
            added = true;
          }
          packages[package]!.add(title);
        }
      }
    }
    return packages;
  }

  BankBloc() : super(const BankInitial()) {
    // --- Initial Load Event ---
    on<LoadInitialBank>((event, emit) async {
      emit(BankLoading());
      await _initialLoad();
      _getKeys();
      return emit(BankLoaded(titles: _titles));
    });

    on<AddNewEntry>((event, emit) {
      ProgressionBank.add(
        package: event.location.package,
        title: event.location.title,
        entry: ProgressionBankEntry(
          progression: ScaleDegreeProgression.empty(),
        ),
      );
      _addTitle(event.location);
      return emit(
          AddedNewEntry(titles: _titles, addEntryLocation: event.location));
    });
    // Since we never rename a progression from the library screen we don't
    // have to rebuild yet.
    on<RenameEntry>((event, emit) {
      ProgressionBank.rename(
          package: event.location.package,
          previousTitle: event.location.title,
          newTitle: event.newTitle);
      bool selected =
          _titles[event.location.package]!.remove(event.location.title)!;
      _addTitle(
          EntryLocation(event.location.package, event.newTitle), selected);
      return emit(RenamedEntry(titles: _titles, newEntryName: event.newTitle));
    });
    on<OverrideEntry>((event, emit) {
      if (ProgressionBank.bank.containsKey(event.location.package) &&
          ProgressionBank.bank[event.location.package]!
              .containsKey(event.location.title)) {
        ProgressionBank.add(
            package: event.location.package,
            title: event.location.title,
            entry: ProgressionBank.getAtLocation(event.location)!
                .copyWith(progression: event.progression));
      }
    });
    on<ChangeUseInSubstitutions>((event, emit) {
      ProgressionBank.changeUseInSubstitutions(
          package: event.location.package,
          title: event.location.title,
          useInSubstitutions: event.useInSubstitutions);
    });
    on<SelectEntry>((event, emit) {
      _titles[event.location.package]![event.location.title] = event.selected;
      _setPackageHasTitleSelected(event.location.package);
      return emit(SpecificSelectionUpdated(
        titles: _titles,
        updated: [event.location],
        selected: [event.selected],
      ));
    });
    on<SelectPackage>((event, emit) {
      for (String title in _titles[event.package]!.keys) {
        _titles[event.package]![title] = event.selected;
      }
      _setPackageHasTitleSelected(event.package);
      return emit(PackageSelectionUpdated(
        titles: _titles,
        package: event.package,
        selected: event.selected,
      ));
    });

    // --- Save Points ---
    on<DeleteEntries>((event, emit) async {
      for (EntryLocation location in event.locations) {
        ProgressionBank.remove(
            package: location.package, title: location.title);
        _titles[location.package]!.remove(location.title);
      }
      _setHasTitleSelected();
      emit(BankLoading());
      await _saveBankData();
      return emit(BankLoaded(titles: _titles));
    });
    on<RevertAll>((event, emit) async {
      emit(BankLoading());
      ProgressionBank.initializeBuiltIn();
      await _saveBankData();
      _getKeys();
      return emit(BankLoaded(titles: _titles));
    });
    on<SaveToJson>((event, emit) async {
      emit(BankLoading());
      await _saveBankData();
      return emit(BankLoaded(titles: _titles));
    });
    on<SaveAndCloseWindow>((event, emit) async {
      emit(BankLoading());
      await _saveBankData();
      emit(BankLoaded(titles: _titles));
      return emit(const ClosingWindow());
    });
    on<MoveEntries>((event, emit) async {
      List<EntryLocation> moved = [];
      for (EntryLocation location in event.currentLocations) {
        ProgressionBank.move(location: location, newPackage: event.newPackage);
        final String title = location.title;
        bool selected = _titles[location.package]!.remove(title)!;
        Map<String, bool>? saved =
            _titles[event.newPackage] ?? _addPackage(event.newPackage);
        saved[title] = selected;
        moved.add(EntryLocation(event.newPackage, title));
      }
      _setHasTitleSelected();
      emit(MovedEntries(titles: _titles, newLocations: moved));
      emit(BankLoading());
      await _saveBankData();
      return emit(BankLoaded(titles: _titles));
    });
    on<CreatePackage>((event, emit) async {
      ProgressionBank.bank[event.package] = {};
      // To make sure built-in is last...
      _addPackage(event.package);
      emit(CreatedPackage(titles: _titles, package: event.package));
      emit(BankLoading());
      await _saveBankData();
      return emit(BankLoaded(titles: _titles));
    });
    on<DeletePackage>((event, emit) async {
      ProgressionBank.removePackage(event.package);
      _titles.remove(event.package);
      _packageHasSelected.remove(event.package);
      emit(DeletedPackage(titles: _titles, package: event.package));
      emit(BankLoading());
      await _saveBankData();
      return emit(BankLoaded(titles: _titles));
    });
    on<ImportPackages>((event, emit) async {
      final List<String> failed = [];
      final List<String> imported = [];
      for (String url in event.jsonFileUrls) {
        try {
          final File file = File(url);
          final Map<String, dynamic> json = jsonDecode(file.readAsStringSync());
          ProgressionBank.importPackages(json);
          imported.add(url);
        } catch (e) {
          failed.add(url);
          continue;
        }
      }
      _getKeys();
      if (failed.isNotEmpty) {
        emit(ImportPackagesFailed(titles: _titles, failedJsonFileUrls: failed));
      }
      emit(ImportedPackages(titles: _titles, importedUrls: imported));
      emit(BankLoading());
      await _saveBankData();
      return emit(BankLoaded(titles: _titles));
    });
    on<ExportPackages>((event, emit) async {
      String directory = event.directory;
      if (!directory.endsWith('.json')) directory += '.json';
      File file = File(directory);
      Map<String, dynamic> json =
          ProgressionBank.exportPackages(event.packages);
      await file.writeAsString(jsonEncode(json));
      return emit(ExportedPackages(
          titles: _titles, packages: event.packages, directory: directory));
    });
  }

  // TODO: Could try to optimize uses of this...
  _setHasTitleSelected() {
    _packageHasSelected = {};
    for (String package in _titles.keys) {
      _setPackageHasTitleSelected(package);
    }
  }

  _setPackageHasTitleSelected(String package) {
    var selected = _titles[package]!.values.where((e) => e);
    if (selected.isEmpty) {
      _packageHasSelected[package] = false;
    } else if (selected.length == _titles[package]!.length) {
      _packageHasSelected[package] = true;
    } else {
      _packageHasSelected[package] = null;
    }
  }

  Map<String, bool> _addPackage(String package) {
    // To make sure built-in is last...
    Map<String, bool>? builtIn =
        _titles.remove(ProgressionBank.builtInPackageName);
    _titles[package] = {};
    _packageHasSelected[package] = false;
    if (builtIn != null) {
      _titles[ProgressionBank.builtInPackageName] = builtIn;
    }
    return _titles[package]!;
  }

  _getKeys() {
    Map<String, Map<String, bool>> _newTitles = {};
    for (MapEntry<String, Map<String, ProgressionBankEntry>> package
        in ProgressionBank.bank.entries) {
      if (package.key != ProgressionBank.builtInPackageName) {
        _newTitles[package.key] = {
          for (String title in package.value.keys)
            title: _titles[package.key]?[title] ?? false,
        };
        package.value.keys.toList();
      }
    }
    if (ProgressionBank.bank.containsKey(ProgressionBank.builtInPackageName)) {
      _newTitles[ProgressionBank.builtInPackageName] = {
        for (String title
            in ProgressionBank.bank[ProgressionBank.builtInPackageName]!.keys)
          title: _titles[ProgressionBank.builtInPackageName]?[title] ?? false,
      };
    }
    _titles = _newTitles;
    _setHasTitleSelected();
  }

  _addTitle(EntryLocation location, [bool selected = false]) {
    if (!_titles.containsKey(location.package)) _addPackage(location.package);
    _titles[location.package]![location.title] = selected;
  }

  Future<void> _initialLoad() async {
    final directory = await getApplicationDocumentsDirectory();
    appDirectory = directory.path;
    jsonPath = '$appDirectory\\$jsonFilePath';
    jsonFile = File(jsonPath);
    bool exists = await jsonFile.exists();
    if (exists) {
      try {
        final String json = await jsonFile.readAsString();
        final Map<String, dynamic> jsonMap = jsonDecode(json);
        if (ProgressionBank.migrationRequired(jsonMap)) {
          final String version =
              ProgressionBank.jsonVersion(jsonMap).replaceAll('.', '-');
          final File backupFile =
              File('$appDirectory\\$backupFilePath\\bank $version.json');
          await backupFile.create(recursive: true);
          await backupFile.writeAsString(json);
        }
        ProgressionBank.initializeFromJson(jsonMap);
      } catch (e) {
        await jsonFile.delete();
        exists = false;
      }
    }
    if (!exists) {
      try {
        ProgressionBank.initializeBuiltIn();
        await jsonFile.create(recursive: true);
        await jsonFile.writeAsString(jsonEncode(ProgressionBank.toJson()));
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Overrides the current data if present. If not re-creates the json file.
  Future<void> _saveBankData() async {
    final String json = jsonEncode(ProgressionBank.toJson());
    await jsonFile.writeAsString(json, mode: FileMode.write);
  }
}

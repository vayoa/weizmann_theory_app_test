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

  late Map<String, List<String>> _titles;

  Map<String, List<String>> get titles => _titles;

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
      _titles[event.location.package]!.remove(event.location.title);
      _addTitle(EntryLocation(event.location.package, event.newTitle));
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
    on<MoveEntry>((event, emit) {
      ProgressionBank.move(
          location: event.currentLocation, newPackage: event.newPackage);
      final String title = event.currentLocation.title;
      _titles[event.currentLocation.package]!.remove(title);
      List<String>? saved = _titles[event.newPackage];
      if (saved == null) {
        _titles[event.newPackage] = [title];
      } else {
        saved.add(title);
      }
      return emit(MovedEntry(
          titles: _titles,
          newLocation: EntryLocation(event.newPackage, title)));
    });
    on<ChangeUseInSubstitutions>((event, emit) {
      ProgressionBank.changeUseInSubstitutions(
          package: event.location.package,
          title: event.location.title,
          useInSubstitutions: event.useInSubstitutions);
    });

    // --- Save Points ---
    on<DeleteEntry>((event, emit) async {
      ProgressionBank.remove(
          package: event.location.package, title: event.location.title);
      emit(BankLoading());
      await _saveBankData();
      _titles[event.location.package]!.remove(event.location.title);
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
  }

  _getKeys() => _titles = {
        for (MapEntry<String, Map<String, ProgressionBankEntry>> package
            in ProgressionBank.bank.entries)
          package.key: package.value.keys.toList(),
      };

  _addTitle(EntryLocation location) {
    if (!_titles.containsKey(location.package)) _titles[location.package] = [];
    _titles[location.package]!.add(location.title);
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
        ProgressionBank.initializeFromJson(jsonDecode(json));
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

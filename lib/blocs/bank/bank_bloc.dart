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

  late List<String> _titles;

  List<String> get titles => _titles;

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
        title: event.title,
        entry: ProgressionBankEntry(
          progression: ScaleDegreeProgression.empty(),
        ),
      );
      _titles.add(event.title);
      return emit(AddedNewEntry(titles: _titles, addedEntryTitle: event.title));
    });
    // Since we never rename a progression from the library screen we don't
    // have to rebuild yet.
    on<RenameEntry>((event, emit) {
      ProgressionBank.rename(
          previousTitle: event.previousTitle, newTitle: event.newTitle);
      _titles.remove(event.previousTitle);
      _titles.add(event.newTitle);
      return emit(RenamedEntry(titles: _titles, newEntryName: event.newTitle));
    });
    on<OverrideEntry>((event, emit) {
      if (ProgressionBank.bank.containsKey(event.title)) {
        ProgressionBank.add(
            title: event.title,
            entry: ProgressionBank.bank[event.title]!
                .copyWith(progression: event.progression));
      }
    });
    on<ChangeUseInSubstitutions>((event, emit) {
      ProgressionBank.changeUseInSubstitutions(
          title: event.title, useInSubstitutions: event.useInSubstitutions);
    });

    // --- Save Points ---
    on<DeleteEntry>((event, emit) async {
      ProgressionBank.remove(event.title);
      emit(BankLoading());
      await _saveBankData();
      _titles.remove(event.title);
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

  _getKeys() => _titles = ProgressionBank.bank.keys.toList();

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

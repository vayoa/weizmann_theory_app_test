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

  bool _bankLoaded = false;
  late List<String> _titles;

  bool get bankLoaded => _bankLoaded;

  BankBloc() : super(const BankInitial()) {
    on<LoadInitialBank>((event, emit) async {
      _bankLoaded = false;
      emit(BankLoading());
      await _initialLoad();
      _getKeys();
      return emit(BankLoaded(titles: _titles));
    });
    on<AddNewEntry>((event, emit) async {
      ProgressionBank.add(
        title: event.title,
        entry: ProgressionBankEntry(
          progression: ScaleDegreeProgression.empty(),
        ),
      );
      _bankLoaded = false;
      emit(BankLoading());
      await _saveBankData();
      _titles.add(event.title);
      _bankLoaded = true;
      emit(AddedNewEntry(titles: _titles, addedEntryTitle: event.title));
      return emit(BankLoaded(titles: _titles));
    });
    on<DeleteEntry>((event, emit) async {
      ProgressionBank.remove(event.title);
      _bankLoaded = false;
      emit(BankLoading());
      await _saveBankData();
      _titles.remove(event.title);
      _bankLoaded = true;
      return emit(BankLoaded(titles: _titles));
    });
    on<RevertAll>((event, emit) async {
      _bankLoaded = false;
      emit(BankLoading());
      ProgressionBank.initializeBuiltIn();
      await _saveBankData();
      _bankLoaded = true;
      _getKeys();
      return emit(BankLoaded(titles: _titles));
    });

    // TODO: Not sure this is the right place...
    add(LoadInitialBank());
  }

  _getKeys() {
    if (_bankLoaded) {
      _titles = ProgressionBank.bank.keys.toList();
    }
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
        _bankLoaded = true;
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
        _bankLoaded = true;
      } catch (e) {
        // TODO: Handle case...
        rethrow;
      }
    }
  }

  /* TODO: Maybe instead of always re-creating the file, remove only what's
          necessary. */

  /// Overrides the current data if present. If not re-creates the json file.
  Future<void> _saveBankData() async {
    final String json = jsonEncode(ProgressionBank.toJson());
    jsonFile.writeAsString(json, mode: FileMode.write);
  }
}

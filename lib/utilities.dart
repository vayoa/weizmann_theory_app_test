import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/tonicized_scale_degree_chord.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/widgets/dialogs.dart';

import 'Constants.dart';
import 'blocs/bank/bank_bloc.dart';

abstract class Utilities {
  static String progressionValueToString<T>(T value) => value == null
      ? '//'
      : (value is Chord ? value.commonName : value.toString());

  static String abbr(ChordPattern pattern) {
    switch (pattern.abbr) {
      case 'min7':
        return 'm7';
      case 'maj7':
        return '∆7';
      case 'min/maj7':
        return 'mΔ7';
      default:
        return pattern.abbr;
    }
  }

  static List<String> cutProgressionValue<T>(T value) {
    assert(value == null || value is Chord || value is ScaleDegreeChord);
    if (value == null) {
      return ['//', ''];
    } else if (value is Chord) {
      Pitch root = value.root;
      return [
        '${root.letterName}${root.accidentalsString}',
        abbr(value.pattern)
      ];
    } else {
      ScaleDegreeChord chord = value as ScaleDegreeChord;
      String _rootDegreeStr = chord.rootDegreeString;
      String _patternStr = chord.patternString;
      if (value is TonicizedScaleDegreeChord) {
        _rootDegreeStr = value.tonicizedToTonic.rootDegreeString;
        _patternStr += '/${value.tonic.rootDegreeString}';
      }
      return [_rootDegreeStr, _patternStr];
    }
  }

  /// returns [sM, sI, eM, eI]
  static List<int> calculateRangePositions({
    required Progression progression,
    required List<Progression> measures,
    required int fromChord,
    required int toChord,
    required double startDur,
    required double? endDur,
  }) {
    double decimal = progression.timeSignature.decimal;
    double durationToStart = progression.durations.real(fromChord) -
        progression.durations[fromChord] +
        startDur;
    int startMeasure = durationToStart ~/ decimal;
    int startIndex =
        measures[startMeasure].getPlayingIndex(durationToStart % decimal);
    // We divide decimal by 2 and subtract it here so that for instance 3.0
    // where the chord at toChord is with a duration of 1.0 (meaning the
    // duration to him was 2.0 and he starts at the first position of his
    // measure) would give us the endMeasure of 2 (the 3rd measure and not the
    // endMeasure of 3 which it would've given if we didn't subtract...).
    double durationWithEnd = progression.durations.real(toChord) -
        (progression.timeSignature.step / 2);
    if (endDur != null) {
      durationWithEnd += endDur - progression.durations[toChord];
    }
    int endMeasure = durationWithEnd ~/ decimal;
    int endIndex =
        measures[endMeasure].getPlayingIndex(durationWithEnd % decimal);
    return [startMeasure, startIndex, endMeasure, endIndex];
  }

  /// Gets [prog], [start] as the start duration of the range and [end] as the
  /// end duration of the range.
  ///
  /// Returns the range positions as [fromChord, startDur, toChord, endDur].
  static List<double>? calculateDurationPositions(
      Progression prog, double start, double end) {
    assert(start >= 0.0 && end <= prog.duration && start < end);
    double realEnd = end - (prog.timeSignature.step / 2);
    int newFromChord = prog.getPlayingIndex(start),
        newToChord = prog.getPlayingIndex(realEnd);
    if (newToChord >= newFromChord) {
      int fromChord = newFromChord;
      int toChord = newToChord;
      double startDur =
          start - (prog.durations.real(fromChord) - prog.durations[fromChord]);
      double endDur =
          end - (prog.durations.real(toChord) - prog.durations[toChord]);
      return [fromChord.toDouble(), startDur, toChord.toDouble(), endDur];
    }
    return null;
  }

  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(text)),
    );
  }

  static Future<void> createNewEntryDialog(
    BuildContext context, {
    String package = ProgressionBank.defaultPackageName,
  }) async {
    String? _title = await showGeneralDialog<String>(
      context: context,
      barrierLabel: 'New Entry',
      barrierDismissible: true,
      pageBuilder: (context, _, __) => GeneralDialogTextField(
        title: const Text(
          'Create a new entry named...',
          style: Constants.valuePatternTextStyle,
          textAlign: TextAlign.center,
        ),
        maxLength: Constants.maxTitleCharacters,
        autoFocus: true,
        submitButtonName: 'Create',
        onCancelled: (text) => Navigator.pop(context),
        onSubmitted: (text) {
          text = text.trim();
          if (text.isEmpty || RegExp(r'^\s*$').hasMatch(text)) {
            return "Entry titles can't be empty.";
          } else if (ProgressionBank.bank.containsKey(package) &&
              ProgressionBank.bank[package]!.containsKey(text)) {
            return 'Title already exists in bank.';
          } else {
            Navigator.pop(context, text);
            return null;
          }
        },
      ),
    );
    if (_title != null) {
      BlocProvider.of<BankBloc>(context)
          .add(AddNewEntry(EntryLocation(package, _title)));
    }
  }
}

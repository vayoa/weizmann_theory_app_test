import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/modals/pitch_chord.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
import 'package:harmony_theory/modals/theory_base/degree/degree_chord.dart';
import 'package:harmony_theory/modals/theory_base/degree/tonicized_degree_chord.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:tonic/tonic.dart';

import '../widgets/dialogs.dart';
import 'blocs/bank/bank_bloc.dart';
import 'constants.dart';

abstract class Utilities {
  static String progressionValueToEditString<T>(T value) => value == null
      ? '//'
      : (value is DegreeChord ? value.inputString : value.toString());

  static List<String> progressionEdit<T>(Progression<T> prog) => [
        for (int i = 0; i < prog.length; i++)
          "${progressionValueToEditString(prog[i])} "
              "${(prog.durations[i] ~/ prog.timeSignature.step)}"
      ];

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
    assert(value == null || value is PitchChord || value is DegreeChord);
    if (value == null) {
      return ['//', ''];
    } else if (value is PitchChord) {
      Pitch root = value.root;
      return [
        '${root.letterName}${root.accidentalsString}',
        abbr(value.pattern) + value.bassString,
      ];
    } else {
      DegreeChord chord = value as DegreeChord;
      String rootDegreeStr = chord.rootString;
      String patternStr = chord.patternString;
      String tonicization = '';
      if (value is TonicizedDegreeChord) {
        rootDegreeStr = value.tonicizedToTonic.rootString;
        tonicization = '/${value.tonic.rootString}';
      }
      return [
        rootDegreeStr,
        (value.hasDifferentBass ? value.bassString : patternStr) + tonicization,
      ];
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

  static void showSnackBar(BuildContext context, String text,
      [SnackBarType type = SnackBarType.warning]) {
    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    final Color color = getSnackBarTypeColor(type);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(getSnackBarTypeIcon(type), color: color),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: color,
          onPressed: () {},
        ),
      ),
    );
  }

  static Color getSnackBarTypeColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.error:
        return Colors.redAccent;
      case SnackBarType.warning:
        return Colors.orangeAccent;
      case SnackBarType.success:
        return Colors.greenAccent;
      case SnackBarType.hint:
        return Colors.lightBlueAccent;
    }
  }

  static IconData getSnackBarTypeIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.error:
        return Icons.cancel_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.hint:
        return Icons.tips_and_updates_rounded;
    }
  }

  static Future<void> createNewEntryDialog(
    BuildContext context, {
    String package = ProgressionBank.defaultPackageName,
  }) async {
    String? title = await showGeneralDialog<String>(
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
    if (title != null) {
      // TODO: Fix usage of BuildContext after async gap.
      BlocProvider.of<BankBloc>(context)
          .add(AddNewEntry(EntryLocation(package, title)));
    }
  }
}

enum SnackBarType {
  error,
  warning,
  success,
  hint,
}

extension StringExtension on String {
  String capitalize() =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

mixin Compared<T> on Comparable<T> {
  bool operator <=(T other) => compareTo(other) <= 0;

  bool operator >=(T other) => compareTo(other) >= 0;

  bool operator <(T other) => compareTo(other) < 0;

  bool operator >(T other) => compareTo(other) > 0;
}

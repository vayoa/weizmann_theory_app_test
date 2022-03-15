import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/tonicized_scale_degree_chord.dart';
import 'package:tonic/tonic.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:tonic/tonic.dart';

abstract class Utilities {
  static String progressionValueToString<T>(T value) => value == null
      ? '//'
      : (value is Chord ? value.getCommonName() : value.toString());

  static String abbr(ChordPattern pattern) =>
      pattern.abbr == 'min7' ? 'm7' : pattern.abbr;

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
        _patternStr += '/${value.tonic}';
      }
      return [_rootDegreeStr, _patternStr];
    }
  }

  // TODO: Optimize this...
  /// returns [sM, sI, eM, eI]
  static List<int> calculateRangePositions({
    required Progression progression,
    required List<Progression> measures,
    required int fromChord,
    required int toChord,
  }) {
    int startMeasure = -1, startIndex = 0;
    int endMeasure = -1, endIndex = 0;
    double dur1 = progression.sumDurations(0, fromChord);
    startMeasure = dur1 ~/ progression.timeSignature.decimal;
    // We minus this so that we'll get the duration in measure
    double halfStep = (progression.timeSignature.step / 2);
    double dur2 = dur1 +
        progression.durations[toChord] +
        progression.sumDurations(fromChord, toChord) -
        halfStep;
    endMeasure = dur2 ~/ progression.timeSignature.decimal;
    for (int i = 0; i < measures[startMeasure].values.length; i++) {
      if (identical(measures[startMeasure].values[i], progression[fromChord])) {
        startIndex = i;
        break;
      }
    }
    bool found = false;
    for (int i = 0; i < measures[endMeasure].values.length; i++) {
      if (identical(measures[endMeasure].values[i], progression[toChord])) {
        found = true;
        endIndex = i;
      } else if (found) {
        break;
      }
    }
    return [startMeasure, startIndex, endMeasure, endIndex];
  }
}

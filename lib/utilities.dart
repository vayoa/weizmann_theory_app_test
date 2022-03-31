import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/tonicized_scale_degree_chord.dart';
import 'package:tonic/tonic.dart';

abstract class Utilities {
  static String progressionValueToString<T>(T value) => value == null
      ? '//'
      : (value is Chord ? value.commonName : value.toString());

  static String abbr(ChordPattern pattern) => pattern.abbr == 'min7'
      ? 'm7'
      : (pattern.abbr == 'maj7' ? '∆7' : pattern.abbr);

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
    double decimal = progression.timeSignature.decimal;
    double durationToStart = progression.durations.real(fromChord) -
        progression.durations[fromChord];
    int startMeasure = durationToStart ~/ decimal;
    print('calculating');
    int startIndex =
        measures[startMeasure].getPlayingIndex(durationToStart % decimal);
    print('done');
    // We divide decimal by 2 and subtract it here so that for instance 3.0
    // where the chord at toChord is with a duration of 1.0 (meaning the
    // duration to him was 2.0 and he starts at the first position of his
    // measure) would give us the endMeasure of 2 (the 3rd measure and not the
    // endMeasure of 3 which it would've given if we didn't subtract...).
    double durationWithEnd = progression.durations.real(toChord) -
        (progression.timeSignature.step / 2);
    int endMeasure = durationWithEnd ~/ decimal;
    print('calculating');
    int endIndex =
        measures[endMeasure].getPlayingIndex(durationWithEnd % decimal);
    print('done');
    var r = [startMeasure, startIndex, endMeasure, endIndex];
    print(r);
    return r;
  }
}

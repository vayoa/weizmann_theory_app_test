import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/state/substitution_handler.dart';
import 'package:weizmann_theory_app_test/modals/progression_type.dart';

part 'substitution_handler_event.dart';
part 'substitution_handler_state.dart';

class SubstitutionHandlerBloc
    extends Bloc<SubstitutionHandlerEvent, SubstitutionHandlerState> {
  ProgressionType type = ProgressionType.romanNumerals;
  List<Substitution>? _substitutions;
  bool _inSetup = false;

  bool get inSetup => _inSetup;

  ScaleDegreeProgression? _currentProgression;
  int _fromChord = 0, _toChord = 0;
  double _startDur = 0.0;
  double? _endDur;
  bool _keepHarmonicFunction = false;

  bool get keepHarmonicFunction => _keepHarmonicFunction;

  // If we calculate a ChordProgression for a substitution we save it here.
  List<ChordProgression?>? _chordProgressions;
  List<ChordProgression?>? _originalSubs;

  List<Substitution>? get substitutions => _substitutions;

  SubstitutionHandlerBloc() : super(SubstitutionHandlerInitial()) {
    on<SetupReharmonization>((event, emit) {
      _currentProgression = event.progression;
      _fromChord = event.fromChord;
      _toChord = event.toChord;
      _startDur = event.startDur;
      _endDur = event.endDur;
      _inSetup = true;
      emit(SetupPage());
    });
    on<SwitchSubType>((event, emit) {
      type = event.progressionType;
      return emit(TypeChanged(type));
    });
    on<ReharmonizeSubs>((event, emit) {
      bool changedSettings = event.keepHarmonicFunction != null &&
          event.keepHarmonicFunction != _keepHarmonicFunction;
      if ((_substitutions == null && _currentProgression != null) ||
          changedSettings) {
        if (changedSettings) {
          _keepHarmonicFunction = event.keepHarmonicFunction!;
          emit(ChangedSubstitutionSettings());
        }
        emit(
            CalculatingSubstitutions(fromChord: _fromChord, toChord: _toChord));
        print('$_fromChord, $_startDur, ${_toChord + 1}, $_endDur');
        _substitutions = SubstitutionHandler.getRatedSubstitutions(
          _currentProgression!,
          keepHarmonicFunction: _keepHarmonicFunction,
          start: _fromChord,
          startDur: _startDur,
          end: _toChord + 1,
          endDur: _endDur,
        );
        _chordProgressions =
            List.generate(_substitutions!.length, (index) => null);
        _originalSubs = List.generate(_substitutions!.length, (index) => null);
        _inSetup = false;
        return emit(CalculatedSubstitutions(substitutions!));
      }
    });
    on<SurpriseMeSubs>((event, emit) {
      emit(CalculatingSubstitutions(
        fromChord: 0,
        toChord: event.progression.length - 1,
      ));
      // TODO: Give it a scaleDegreeProgression instead...
      _substitutions = [
        SubstitutionHandler.substituteBy(
          base: event.progression,
          maxIterations: 50,
          scale: event.scale,
        )
      ];
      _chordProgressions =
          List.generate(_substitutions!.length, (index) => null);
      _originalSubs = List.generate(_substitutions!.length, (index) => null);
      _inSetup = false;
      return emit(CalculatedSubstitutions(substitutions!));
    });
    on<ClearSubstitutions>((event, emit) {
      _substitutions = null;
      _currentProgression = null;
      _fromChord = 0;
      _toChord = 0;
      _startDur = 0.0;
      _endDur = null;
      _chordProgressions = null;
      _originalSubs = null;
      _inSetup = false;
      return emit(const ClearedSubstitutions());
    });
    on<SetKeepHarmonicFunction>((event, emit) {
      _keepHarmonicFunction = event.keepHarmonicFunction;
      return emit(ChangedSubstitutionSettings());
    });
  }

  Progression getSubstitutedBase(PitchScale? scale, int index) {
    if (scale == null || type == ProgressionType.romanNumerals) {
      return _substitutions![index].substitutedBase;
    } else {
      return getChordProgression(scale, index);
    }
  }

  Progression getOriginalSubstitution(PitchScale? scale, int index) {
    if (scale == null || type == ProgressionType.romanNumerals) {
      return _substitutions![index].originalSubstitution;
    } else {
      return getOriginalSubChords(scale, index);
    }
  }

  ChordProgression getChordProgression(PitchScale scale, int index) {
    assert(index >= 0 && index < _chordProgressions!.length);
    if (_chordProgressions![index] == null) {
      _chordProgressions![index] =
          _substitutions![index].substitutedBase.inScale(scale);
    }
    return _chordProgressions![index]!;
  }

  ChordProgression getOriginalSubChords(PitchScale scale, int index) {
    assert(index >= 0 && index < _originalSubs!.length);
    if (_originalSubs![index] == null) {
      ScaleDegreeProgression originalSub =
          _substitutions![index].originalSubstitution;
      SubstitutionMatch match = _substitutions![index].match;
      if (match.type == SubstitutionMatchType.tonicization) {
        // TODO: Optimize.
        originalSub = originalSub.tonicizedFor(
            _substitutions![index].substitutedBase[match.baseIndex]!);
      }
      _originalSubs![index] = originalSub.inScale(scale);
    }
    return _originalSubs![index]!;
  }
}

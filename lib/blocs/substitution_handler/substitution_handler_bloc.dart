import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:thoery_test/state/substitution_handler.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/modals/progression_type.dart';

part 'substitution_handler_event.dart';
part 'substitution_handler_state.dart';

class SubstitutionHandlerBloc
    extends Bloc<SubstitutionHandlerEvent, SubstitutionHandlerState> {
  final ProgressionBank _bank = ProgressionBank();
  ProgressionType type = ProgressionType.chords;
  List<Substitution>? _substitutions;

  // If we calculate a ChordProgression for a substitution we save it here.
  List<ChordProgression?>? _chordProgressions;
  List<ChordProgression?>? _originalSubs;

  List<Substitution>? get substitutions => _substitutions;

  Progression getSubstitutedBase(Scale scale, int index) {
    if (type == ProgressionType.romanNumerals) {
      return _substitutions![index].substitutedBase;
    } else {
      return getChordProgression(scale, index);
    }
  }

  Progression getOriginalSubstitution(Scale scale, int index) {
    if (type == ProgressionType.romanNumerals) {
      return _substitutions![index].originalSubstitution;
    } else {
      return getOriginalSubChords(scale, index);
    }
  }

  ChordProgression getChordProgression(Scale scale, int index) {
    assert(index >= 0 && index < _chordProgressions!.length);
    if (_chordProgressions![index] == null) {
      _chordProgressions![index] =
          _substitutions![index].substitutedBase.inScale(scale);
    }
    return _chordProgressions![index]!;
  }

  ChordProgression getOriginalSubChords(Scale scale, int index) {
    assert(index >= 0 && index < _originalSubs!.length);
    if (_originalSubs![index] == null) {
      _originalSubs![index] =
          _substitutions![index].originalSubstitution.inScale(scale);
    }
    return _originalSubs![index]!;
  }

  SubstitutionHandlerBloc() : super(SubstitutionHandlerInitial()) {
    on<SwitchSubType>((event, emit) {
      type = event.progressionType;
      return emit(TypeChanged(type));
    });
    on<ReharmonizeSubs>((event, emit) {
      if (_substitutions == null) {
        emit(CalculatingSubstitutions(
            fromChord: event.fromChord, toChord: event.toChord));
        _substitutions = SubstitutionHandler.getRatedSubstitutions(
          event.progression,
          bank: _bank,
          start: event.fromChord,
          end: event.toChord + 1,
        );
        _chordProgressions =
            List.generate(_substitutions!.length, (index) => null);
        _originalSubs = List.generate(_substitutions!.length, (index) => null);
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
          bank: _bank,
          maxIterations: 50,
          scale: event.scale,
        )
      ];
      _chordProgressions =
          List.generate(_substitutions!.length, (index) => null);
      _originalSubs = List.generate(_substitutions!.length, (index) => null);
      return emit(CalculatedSubstitutions(substitutions!));
    });
    on<ClearSubstitutions>((event, emit) {
      _substitutions = null;
      _chordProgressions = null;
      _originalSubs = null;
      return emit(const ClearedSubstitutions());
    });
  }
}

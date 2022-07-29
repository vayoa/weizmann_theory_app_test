import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/modals/progression/chord_progression.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
import 'package:harmony_theory/modals/substitution.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/modals/weights/keep_harmonic_function_weight.dart';
import 'package:harmony_theory/modals/weights/weight.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:harmony_theory/state/substitution_handler.dart';

import '../../modals/progression_type.dart';

part 'substitution_handler_event.dart';
part 'substitution_handler_state.dart';

class SubstitutionHandlerBloc
    extends Bloc<SubstitutionHandlerEvent, SubstitutionHandlerState> {
  ProgressionType type = ProgressionType.romanNumerals;
  List<Substitution>? _substitutions;
  bool _inSetup = false;

  bool get inSetup => _inSetup;

  bool _surpriseMe = false;

  bool get surpriseMe => _surpriseMe;

  DegreeProgression? _currentProgression;
  int _fromChord = 0, _toChord = 0;
  double _startDur = 0.0;
  double? _endDur;
  KeepHarmonicFunctionAmount _keepHarmonicFunction =
      SubstitutionHandler.keepAmount;

  KeepHarmonicFunctionAmount get keepHarmonicFunction => _keepHarmonicFunction;

  Sound _sound = Sound.both;

  Sound get sound => _sound;

  Isolate? _substituteByIsolate;

  // If we calculate a ChordProgression for a substitution we save it here.
  List<ChordProgression?>? _chordProgressions;

  List<Substitution>? get substitutions => _substitutions;

  bool get showingWindow => _substitutions != null || _inSetup;

  bool _showingDrawer = false;

  bool get showingDrawer => _showingDrawer;

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  SubstitutionHandlerBloc() : super(SubstitutionHandlerInitial()) {
    on<OpenSetupPage>((event, emit) {
      _currentProgression = event.progression;
      _fromChord = event.fromChord;
      _toChord = event.toChord ?? event.progression.length - 1;
      _startDur = event.startDur;
      _endDur = event.endDur;
      _inSetup = true;
      _surpriseMe = event.surpriseMe;
      _showingDrawer = true;
      emit(const UpdatedShowSubstitutions(true));
      return emit(SetupPage(surpriseMe: event.surpriseMe));
    });
    on<SwitchSubType>((event, emit) {
      type = event.progressionType;
      return emit(TypeChanged(type));
    });
    on<CalculateSubstitutions>((event, emit) async {
      bool changedSettings =
          event.keepHarmonicFunction != _keepHarmonicFunction ||
              event.sound != _sound;
      if ((_substitutions == null && _currentProgression != null) ||
          changedSettings) {
        int from = _currentIndex;
        _currentIndex = 0;
        emit(ChangedSubstitutionIndex(from, _currentIndex));
        if (changedSettings) {
          _keepHarmonicFunction = event.keepHarmonicFunction;
          _sound = event.sound;
          emit(ChangedSubstitutionSettings());
        }
        emit(
            CalculatingSubstitutions(fromChord: _fromChord, toChord: _toChord));
        if (_surpriseMe) {
          _substitutions = [await _isolateSubstituteBy(50)];
          _handleCalculatedSubstitutions(emit);
          SubstitutionHandler.keepAmount = _keepHarmonicFunction;
        } else {
          _substitutions = SubstitutionHandler.getRatedSubstitutions(
            _currentProgression!,
            sound: _sound,
            keepAmount: _keepHarmonicFunction,
            start: _fromChord,
            startDur: _startDur,
            end: _toChord + 1,
            endDur: _endDur,
          );
          return _handleCalculatedSubstitutions(emit);
        }
      }
    });
    on<ClearSubstitutions>((event, emit) {
      _substitutions = null;
      _currentProgression = null;
      _fromChord = 0;
      _toChord = 0;
      _startDur = 0.0;
      _endDur = null;
      _chordProgressions = null;
      _inSetup = false;
      _currentIndex = 0;
      _showingDrawer = false;
      emit(const UpdatedShowSubstitutions(false));
      if (_substituteByIsolate != null) {
        _substituteByIsolate!.kill(priority: Isolate.immediate);
        _substituteByIsolate = null;
      }
      return emit(const ClearedSubstitutions());
    });
    on<SetKeepHarmonicFunction>((event, emit) {
      _keepHarmonicFunction = event.keepHarmonicFunction;
      return emit(ChangedSubstitutionSettings());
    });
    on<UpdateShowSubstitutions>((event, emit) {
      if (event.show != _showingDrawer) {
        _showingDrawer = event.show;
        return emit(UpdatedShowSubstitutions(event.show));
      }
    });
    on<ChangeSubstitutionIndex>((event, emit) {
      if (_substitutions != null && _substitutions!.isNotEmpty) {
        return _handleChangeIndex(emit, event.changeTo);
      }
    });
    on<ChangeSubstitutionIndexInOrder>((event, emit) {
      if (_substitutions != null && _substitutions!.isNotEmpty) {
        _handleChangeIndex(emit, _currentIndex + (event.forward ? 1 : -1));
      }
    });
  }

  void _handleChangeIndex(Emitter<SubstitutionHandlerState> emit, int to) {
    int from = _currentIndex;
    _currentIndex = to % _substitutions!.length;
    return emit(ChangedSubstitutionIndex(from, _currentIndex));
  }

  void _handleCalculatedSubstitutions(Emitter<SubstitutionHandlerState> emit) {
    _chordProgressions = List.generate(_substitutions!.length, (index) => null);
    _inSetup = false;
    return emit(CalculatedSubstitutions(
      substitutions: substitutions!,
      surpriseMe: _surpriseMe,
    ));
  }

  Progression getSubstitutedBase(PitchScale? scale, int index) {
    if (scale == null || type == ProgressionType.romanNumerals) {
      return _substitutions![index].substitutedBase;
    } else {
      return getChordProgression(scale, index);
    }
  }

  Progression getOriginalSubstitution(PitchScale? scale, int index) =>
      _substitutions![index].originalSubstitution;

  ChordProgression getChordProgression(PitchScale scale, int index) {
    assert(index >= 0 && index < _chordProgressions!.length);
    if (_chordProgressions![index] == null) {
      _chordProgressions![index] =
          _substitutions![index].substitutedBase.inScale(scale);
    }
    return _chordProgressions![index]!;
  }

  /// Creates an [Isolate] to compute the substitution. The isolate will be
  /// saved in [_substituteByIsolate] until it is complete.
  Future<Substitution> _isolateSubstituteBy(int iterations) async {
    // Receive port for result
    ReceivePort port = ReceivePort("SubstituteByPort");

    _SubstituteByComputeModal modal = _SubstituteByComputeModal(
      base: _currentProgression!,
      iterations: iterations,
      sound: _sound,
      keepAmount: _keepHarmonicFunction,
      computePass: ProgressionBank.createComputePass(),
    );

    // Spawn the isolate, pass the sendPort to our port.
    _substituteByIsolate = await Isolate.spawn<List<dynamic>>(
        _substituteByEntryPoint, [port.sendPort, modal]);

    // await the result
    final result = await port.first;
    _substituteByIsolate!.kill(priority: Isolate.immediate);
    _substituteByIsolate = null;
    return result;
  }

  /// First element of [values] should be the desired [SendPort] and the second
  /// the relevant [_SubstituteByComputeModal].
  static void _substituteByEntryPoint(List<dynamic> values) {
    SendPort sendPort = values[0];
    _SubstituteByComputeModal modal = values[1];
    ProgressionBank.initializeFromComputePass(modal.computePass);
    sendPort.send(SubstitutionHandler.substituteBy(
      base: modal.base,
      maxIterations: modal.iterations,
      sound: modal.sound,
      keepHarmonicFunction: modal.keepAmount,
    ));
  }
}

class _SubstituteByComputeModal {
  final Sound sound;
  final KeepHarmonicFunctionAmount keepAmount;
  final DegreeProgression base;
  final int iterations;
  final ProgressionBankComputePass computePass;

  const _SubstituteByComputeModal({
    required this.base,
    required this.iterations,
    required this.sound,
    required this.keepAmount,
    required this.computePass,
  });
}

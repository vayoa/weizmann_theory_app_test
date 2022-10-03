part of 'update_cubit.dart';

abstract class UpdateState extends Equatable {
  final Version version;

  @override
  List<Object?> get props => [version];

  const UpdateState(this.version);
}

class UpdateInitial extends UpdateState {
  const UpdateInitial(Version version) : super(version);
}

class UpdateLoading extends UpdateState {
  const UpdateLoading(Version version) : super(version);
}

class UpdateAvailable extends UpdateState {
  final Version update;

  @override
  List<Object?> get props => [version, update];

  const UpdateAvailable({required Version version, required this.update})
      : super(version);
}

class FullyUpdated extends UpdateState {
  const FullyUpdated(Version version) : super(version);
}

// Step In Progress
class StepInProgress extends UpdateAvailable {
  final double progress;
  final String message;

  @override
  List<Object?> get props => [version, update, progress, message];

  const StepInProgress(this.message,
      {required Version version, required Version update, double? progress})
      : progress = progress ?? 0,
        super(version: version, update: update);
}

class DownloadingUpdate extends StepInProgress {
  const DownloadingUpdate(
      {required Version version, required Version update, double? progress})
      : super("Downloading Update",
            version: version, update: update, progress: progress);
}

class ExtractingUpdate extends StepInProgress {
  const ExtractingUpdate(
      {required Version version, required Version update, double? progress})
      : super("Extracting Update",
            version: version, update: update, progress: progress);
}

// Step Finished
class StepFinished extends UpdateAvailable {
  final String finished;
  final String message;

  @override
  List<Object?> get props => [...super.props, finished, message];

  const StepFinished(
      {required this.finished,
      required this.message,
      required Version version,
      required Version update})
      : super(version: version, update: update);
}

class UpdateDownloaded extends StepFinished {
  const UpdateDownloaded({required Version version, required Version update})
      : super(
            finished: "Update Downloaded.",
            message: "We'll now unzip the file.",
            version: version,
            update: update);
}

class UpdateExtracted extends StepFinished {
  final String location;

  @override
  List<Object?> get props => [...super.props, location];

  const UpdateExtracted(
      {required this.location,
      required Version version,
      required Version update})
      : super(
            finished: "Zip Extracted.",
            message: "Close this app and open the new one\n"
                "at $location.",
            version: version,
            update: update);
}

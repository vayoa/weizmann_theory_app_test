part of 'bank_bloc.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();
}

class LoadInitialBank extends BankEvent {
  @override
  List<Object?> get props => const [];
}

class DeleteEntry extends BankEvent {
  final EntryLocation location;

  @override
  List<Object?> get props => [location];

  const DeleteEntry(this.location);
}

class RevertAll extends BankEvent {
  @override
  List<Object?> get props => const [];

  const RevertAll();
}

class AddNewEntry extends BankEvent {
  final EntryLocation location;

  @override
  List<Object?> get props => [location];

  const AddNewEntry(this.location);
}

class RenameEntry extends BankEvent {
  final EntryLocation location;
  final String newTitle;

  @override
  List<Object?> get props => [location, newTitle];

  const RenameEntry({required this.location, required this.newTitle});
}

class SaveToJson extends BankEvent {
  @override
  List<Object?> get props => const [];

  const SaveToJson();
}

class OverrideEntry extends BankEvent {
  final EntryLocation location;
  final ScaleDegreeProgression progression;

  @override
  List<Object?> get props => [location, progression];

  const OverrideEntry({required this.location, required this.progression});
}

class MoveEntry extends BankEvent {
  final EntryLocation currentLocation;
  final String newPackage;

  @override
  List<Object?> get props => [currentLocation, newPackage];

  const MoveEntry({
    required this.currentLocation,
    required this.newPackage,
  });
}

class SaveAndCloseWindow extends BankEvent {
  @override
  List<Object?> get props => const [];

  const SaveAndCloseWindow();
}

class ChangeUseInSubstitutions extends BankEvent {
  final EntryLocation location;
  final bool useInSubstitutions;

  @override
  List<Object?> get props => [location, useInSubstitutions];

  const ChangeUseInSubstitutions(
      {required this.location, required this.useInSubstitutions});
}

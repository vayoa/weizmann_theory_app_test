part of 'bank_bloc.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();
}

class LoadInitialBank extends BankEvent {
  @override
  List<Object?> get props => const [];
}

class DeleteEntries extends BankEvent {
  final List<EntryLocation> locations;

  @override
  List<Object?> get props => [locations];

  const DeleteEntries(this.locations);
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

class MoveEntries extends BankEvent {
  final List<EntryLocation> currentLocations;
  final String newPackage;

  @override
  List<Object?> get props => [currentLocations, newPackage];

  MoveEntries({
    required this.currentLocations,
    required this.newPackage,
  }) : assert(currentLocations.isNotEmpty);
}

class CreatePackage extends BankEvent {
  final String package;

  @override
  List<Object?> get props => [package];

  const CreatePackage({required this.package});
}

class DeletePackage extends BankEvent {
  final String package;

  @override
  List<Object?> get props => [package];

  const DeletePackage({required this.package});
}

class ImportPackages extends BankEvent {
  final List<String> jsonFileUrls;

  @override
  List<Object?> get props => [jsonFileUrls];

  const ImportPackages({required this.jsonFileUrls});
}

class ExportPackages extends BankEvent {
  final Map<String, List<String>> packages;
  final String directory;

  @override
  List<Object?> get props => [packages, directory];

  const ExportPackages({required this.packages, required this.directory});
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

class SelectEntry extends BankEvent {
  final EntryLocation location;
  final bool selected;

  @override
  List<Object?> get props => [location, selected];

  const SelectEntry({required this.location, required this.selected});
}

class SelectPackage extends BankEvent {
  final String package;
  final bool selected;

  @override
  List<Object?> get props => [package, selected];

  const SelectPackage({required this.package, required this.selected});
}

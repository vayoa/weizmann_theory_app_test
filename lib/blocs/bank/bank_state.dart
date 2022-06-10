part of 'bank_bloc.dart';

/* TODO: NOTICE!!!
    This is the same map in every bank state, so we can't relay on it for
    equality: The map itself changes in both states, previous and new.
    ...
    So we can either copy the map, or just not relay on it for the state
    equality, and always make sure we're adding another field.
*/
abstract class BankState extends Equatable {
  final Map<String, Map<String, bool>> titles;

  @override
  List<Object?> get props => [titles];

  const BankState(this.titles);
}

// --- Types ---
/// Describes only database updates that don't include selection updates.
abstract class DatabaseUpdated extends BankState {
  const DatabaseUpdated(Map<String, Map<String, bool>> titles) : super(titles);
}

/// Describes only selection updates...
abstract class SelectionUpdated extends BankState {
  const SelectionUpdated(Map<String, Map<String, bool>> titles) : super(titles);
}

class BankLoading extends BankInitial {}

class BankInitial extends DatabaseUpdated {
  const BankInitial() : super(const {});
}

class BankLoaded extends DatabaseUpdated {
  const BankLoaded({required Map<String, Map<String, bool>> titles})
      : super(titles);
}

class ClosingWindow extends BankInitial {
  const ClosingWindow();
}

class AddedNewEntry extends DatabaseUpdated {
  final EntryLocation addEntryLocation;

  @override
  List<Object?> get props => [...super.props, addEntryLocation];

  const AddedNewEntry({
    required Map<String, Map<String, bool>> titles,
    required this.addEntryLocation,
  }) : super(titles);
}

class RenamedEntry extends DatabaseUpdated {
  final String newEntryName;

  @override
  List<Object?> get props => [...super.props, newEntryName];

  const RenamedEntry({
    required Map<String, Map<String, bool>> titles,
    required this.newEntryName,
  }) : super(titles);
}

class MovedEntries extends DatabaseUpdated {
  final List<EntryLocation> newLocations;

  @override
  List<Object?> get props => [...super.props, newLocations];

  const MovedEntries({
    required Map<String, Map<String, bool>> titles,
    required this.newLocations,
  }) : super(titles);
}

class CreatedPackage extends DatabaseUpdated {
  final String package;

  @override
  List<Object?> get props => [...super.props, package];

  const CreatedPackage(
      {required Map<String, Map<String, bool>> titles, required this.package})
      : super(titles);
}

class DeletedPackage extends DatabaseUpdated {
  final String package;

  @override
  List<Object?> get props => [...super.props, package];

  const DeletedPackage(
      {required Map<String, Map<String, bool>> titles, required this.package})
      : super(titles);
}

class ImportedPackages extends DatabaseUpdated {
  final List<String> importedUrls;

  @override
  List<Object?> get props => [...super.props, importedUrls];

  const ImportedPackages({
    required Map<String, Map<String, bool>> titles,
    required this.importedUrls,
  }) : super(titles);
}

class ImportPackagesFailed extends BankState {
  final List<String> failedJsonFileUrls;

  @override
  List<Object?> get props => [failedJsonFileUrls];

  const ImportPackagesFailed(
      {required Map<String, Map<String, bool>> titles,
      required this.failedJsonFileUrls})
      : super(titles);
}

class ExportedPackages extends BankState {
  final Map<String, List<String>> packages;
  final String directory;

  @override
  List<Object?> get props => [...super.props, packages, directory];

  const ExportedPackages(
      {required Map<String, Map<String, bool>> titles,
      required this.packages,
      required this.directory})
      : super(titles);
}

class SpecificSelectionUpdated extends SelectionUpdated {
  final List<EntryLocation> updated;
  final List<bool> selected;

  @override
  List<Object?> get props => [...super.props, updated, selected];

  const SpecificSelectionUpdated({
    required Map<String, Map<String, bool>> titles,
    required this.updated,
    required this.selected,
  }) : super(titles);
}

class PackageSelectionUpdated extends SelectionUpdated {
  final String package;
  final bool selected;

  @override
  List<Object?> get props => [...super.props, package, selected];

  const PackageSelectionUpdated({
    required Map<String, Map<String, bool>> titles,
    required this.package,
    required this.selected,
  }) : super(titles);
}

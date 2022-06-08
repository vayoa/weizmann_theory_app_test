part of 'bank_bloc.dart';

abstract class BankState extends Equatable {
  final Map<String, List<String>> titles;

  @override
  List<Object?> get props => [titles];

  const BankState({required this.titles});
}

class BankInitial extends BankState {
  const BankInitial() : super(titles: const {});
}

class BankLoading extends BankInitial {}

class BankLoaded extends BankState {
  const BankLoaded({required Map<String, List<String>> titles})
      : super(titles: titles);
}

class AddedNewEntry extends BankState {
  final EntryLocation addEntryLocation;

  @override
  List<Object?> get props => [...super.props, addEntryLocation];

  const AddedNewEntry({
    required Map<String, List<String>> titles,
    required this.addEntryLocation,
  }) : super(titles: titles);
}

class RenamedEntry extends BankState {
  final String newEntryName;

  @override
  List<Object?> get props => [...super.props, newEntryName];

  const RenamedEntry({
    required Map<String, List<String>> titles,
    required this.newEntryName,
  }) : super(titles: titles);
}

class MovedEntries extends BankState {
  final List<EntryLocation> newLocations;

  @override
  List<Object?> get props => [...super.props, newLocations];

  const MovedEntries({
    required Map<String, List<String>> titles,
    required this.newLocations,
  }) : super(titles: titles);
}

class CreatedPackage extends BankState {
  final String package;

  @override
  List<Object?> get props => [...super.props, package];

  const CreatedPackage(
      {required Map<String, List<String>> titles, required this.package})
      : super(titles: titles);
}

class DeletedPackage extends BankState {
  final String package;

  @override
  List<Object?> get props => [...super.props, package];

  const DeletedPackage(
      {required Map<String, List<String>> titles, required this.package})
      : super(titles: titles);
}

class ImportedPackages extends BankState {
  @override
  List<Object?> get props => [...super.props];

  const ImportedPackages({required Map<String, List<String>> titles})
      : super(titles: titles);
}

class ImportPackagesFailed extends BankState {
  final List<String> failedJsonFileUrls;

  @override
  List<Object?> get props => [failedJsonFileUrls];

  const ImportPackagesFailed(
      {required Map<String, List<String>> titles,
      required this.failedJsonFileUrls})
      : super(titles: titles);
}

class ExportedPackages extends BankState {
  final List<String> packages;
  final String directory;

  @override
  List<Object?> get props => [...super.props, packages, directory];

  const ExportedPackages(
      {required Map<String, List<String>> titles,
      required this.packages,
      required this.directory})
      : super(titles: titles);
}

class ClosingWindow extends BankInitial {
  const ClosingWindow();
}

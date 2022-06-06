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

class MovedEntry extends BankState {
  final EntryLocation newLocation;

  @override
  List<Object?> get props => [...super.props, newLocation];

  const MovedEntry({
    required Map<String, List<String>> titles,
    required this.newLocation,
  }) : super(titles: titles);
}

class ClosingWindow extends BankInitial {
  const ClosingWindow();
}

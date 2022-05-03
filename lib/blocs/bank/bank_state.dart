part of 'bank_bloc.dart';

abstract class BankState extends Equatable {
  final List<String> titles;

  @override
  List<Object?> get props => [titles];

  const BankState({required this.titles});
}

class BankInitial extends BankState {
  const BankInitial() : super(titles: const []);
}

class BankLoading extends BankInitial {}

class BankLoaded extends BankState {
  const BankLoaded({required List<String> titles}) : super(titles: titles);
}

class AddedNewEntry extends BankState {
  final String addedEntryTitle;

  @override
  List<Object?> get props => [...super.props, addedEntryTitle];

  const AddedNewEntry({
    required List<String> titles,
    required this.addedEntryTitle,
  }) : super(titles: titles);
}

class RenamedEntry extends BankState {
  final String newEntryName;

  @override
  List<Object?> get props => [...super.props, newEntryName];

  const RenamedEntry({
    required List<String> titles,
    required this.newEntryName,
  }) : super(titles: titles);
}

class ClosingWindow extends BankInitial {
  const ClosingWindow();
}

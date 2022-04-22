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

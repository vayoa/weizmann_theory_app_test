part of 'bank_bloc.dart';

abstract class BankEvent extends Equatable {
  const BankEvent();
}

class LoadInitialBank extends BankEvent {
  @override
  List<Object?> get props => const [];
}

class DeleteEntry extends BankEvent {
  final String title;

  @override
  List<Object?> get props => [title];

  const DeleteEntry(this.title);
}

class RevertAll extends BankEvent {
  @override
  List<Object?> get props => const [];

  const RevertAll();
}

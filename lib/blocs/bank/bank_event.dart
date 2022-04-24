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

class AddNewEntry extends BankEvent {
  final String title;

  @override
  List<Object?> get props => [title];

  const AddNewEntry(this.title);
}

class RenameEntry extends BankEvent {
  final String previousTitle;
  final String newTitle;

  @override
  List<Object?> get props => [previousTitle, newTitle];

  const RenameEntry({required this.previousTitle, required this.newTitle});
}

class ExitingProgressionView extends BankEvent {
  @override
  List<Object?> get props => const [];

  const ExitingProgressionView();
}

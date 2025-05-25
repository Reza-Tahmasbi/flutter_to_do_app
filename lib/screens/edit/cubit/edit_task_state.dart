part of 'edit_task_cubit.dart';

@immutable
sealed class EditTaskState {
  final TaskEntity task;

  const EditTaskState(this.task);
}

final class EditTaskInitial extends EditTaskState {
  const EditTaskInitial(super.task);
}

class EditTaskPriorityChange extends EditTaskState {
  const EditTaskPriorityChange(super.task);
}
 
part of 'task_list_bloc.dart';

@immutable
sealed class TaskListState {}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListSuccess extends TaskListState {
    final List<TaskEntity> items;

    TaskListSuccess({required this.items});
}

class TaskListEmpty extends TaskListState {}

class TaskListError extends TaskListState {
    final String errorMessage;
    TaskListError({required this.errorMessage});
}
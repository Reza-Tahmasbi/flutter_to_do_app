import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist/data/repo/repository.dart';
import 'package:todolist/main.dart';
import 'package:todolist/screens/edit/edit.dart';
import 'package:todolist/screens/home/bloc/task_list_bloc.dart';
import 'package:todolist/widgets.dart';

import '../../data/data.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier("_value");

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEntity>(taskBoxName);

    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: TaskEntity()),
            ),
          );
        },
        label: Row(
          children: [
            Text("Add New Task"),
            SizedBox(
              width: 2,
            ),
            Icon(CupertinoIcons.add)
          ],
        ),
      ),
      body: BlocProvider<TaskListBloc>(
        create: (context) =>
            TaskListBloc(context.read<Repository<TaskEntity>>()),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 112,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeData.colorScheme.primaryFixed,
                      themeData.colorScheme.primary,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("To Do List",
                              style: themeData.textTheme.headlineMedium?.apply(
                                color: themeData.colorScheme.onPrimary,
                                fontSizeFactor: 0.8,
                              )),
                          Icon(
                            CupertinoIcons.share,
                            color: themeData.colorScheme.onPrimary,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: 38,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: themeData.colorScheme.onPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            context.read<TaskListBloc>().add(
                                  TaskListSearch(
                                    searchTerm: value,
                                  ),
                                );
                          },
                          controller: _controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              CupertinoIcons.search,
                            ),
                            label: Text("Search tasks..."),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer<Repository<TaskEntity>>(
                    builder: (context, model, child) {
                  context.read<TaskListBloc>().add(TaskListStarted());
                  return BlocBuilder<TaskListBloc, TaskListState>(
                    builder: (
                      context,
                      state,
                    ) {
                      if (state is TaskListSuccess) {
                        return TaskList(
                            items: state.items, themeData: themeData);
                      } else if (state is TaskListEmpty) {
                        return const EmptyState();
                      } else if (state is TaskListLoading ||
                          state is TaskListInitial) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is TaskListError) {
                        return Center(
                            child: Text("Error: ${state.errorMessage}"));
                      } else {
                        throw Exception("Unknown state: $state");
                      }
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.items,
    required this.themeData,
  });

  final List<TaskEntity> items;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today",
                    style: themeData.textTheme.headlineMedium!
                        .apply(fontSizeFactor: 0.6),
                  ),
                  Container(
                    width: 70,
                    height: 3,
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(1.5)),
                  )
                ],
              ),
              MaterialButton(
                color: const Color(0xffEAEFF5),
                textColor: secondaryTextColor,
                elevation: 0,
                onPressed: () {
                  context.read<TaskListBloc>().add(TaskListDeleteAll());
                },
                child: Row(
                  children: const [
                    Text("Delete All"),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(
                      CupertinoIcons.delete_solid,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          final TaskEntity task = items[index - 1];
          return TaskItem(task: task);
        }
      },
    );
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 84;
  static const double borderRadius = 8;
  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;
    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowPriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.high:
        priorityColor = highPriority;
        break;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: widget.task)));
      },
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.only(left: 16),
        width: 24,
        height: TaskItem.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TaskItem.borderRadius),
            color: themeData.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.02),
              )
            ]),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(widget.task.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18,
                      decoration: widget.task.isCompleted
                          ? TextDecoration.lineThrough
                          : null)),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              width: 5,
              height: TaskItem.height,
              decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(TaskItem.borderRadius),
                      bottomRight: Radius.circular(TaskItem.borderRadius))),
            ),
          ],
        ),
      ),
    );
  }
}

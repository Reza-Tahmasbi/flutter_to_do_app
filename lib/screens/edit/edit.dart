import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist/data/data.dart';
import 'package:todolist/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolist/screens/edit/cubit/edit_task_cubit.dart';
import 'package:todolist/screens/home/bloc/task_list_bloc.dart';
import 'package:todolist/data/repo/repository.dart';
import 'package:provider/provider.dart';

class EditTaskScreen extends StatefulWidget {

  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: context.read<EditTaskCubit>().state.task.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
        title: const Text("Edit Task"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          context.read<EditTaskCubit>().onSaveChangesClick();
          try {
            // Force refresh the repository
            if (!context.mounted) return;
            final repository = context.read<Repository<TaskEntity>>();
            await repository.getAll(); // Force a refresh

            // Update UI state
            if (!context.mounted) return;
            context.read<TaskListBloc>().add(TaskListStarted());

            // Navigate back
            if (!context.mounted) return;
            Navigator.pop(context);

            // Force a rebuild of the home screen
            if (!context.mounted) return;
            Future.delayed(Duration(milliseconds: 100), () {
              if (!context.mounted) return;
              context.read<TaskListBloc>().add(TaskListStarted());
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving task: $e')),
            );
          }
        },
        label: Row(
          children: const [
            Text("Save Changes"),
            Icon(CupertinoIcons.check_mark),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          BlocBuilder<EditTaskCubit, EditTaskState>(
              builder: (context, state) {
                final priority = state.task.priority;
                return Flex(
                direction: Axis.horizontal, 
                children: [ 
                  Flexible(
                    flex: 1,
                    child: PriorityCheckBox(
                      onTap: () {
                        context.read<EditTaskCubit>().onPriorityChanged(Priority.high);
                      },
                      label: "High",
                      color: highPriority,
                      isSelected: priority == Priority.high,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    flex: 1,
                    child: PriorityCheckBox(
                        onTap: () {
                          context.read<EditTaskCubit>().onPriorityChanged(Priority.normal);
                        },
                        label: "Normal",
                        color: normalPriority,
                        isSelected: priority == Priority.normal),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    flex: 1,
                    child: PriorityCheckBox(
                        onTap: () {
                            context.read<EditTaskCubit>().onPriorityChanged(Priority.low);
                        },
                        label: "Low",
                        color: lowPriority,
                        isSelected: priority == Priority.low),
                  ),
                ],
              );
              },), 
            TextField(
              controller: _controller,
              onChanged: (value){
                context.read<EditTaskCubit>().onTextChanged(value);
              },
              decoration: InputDecoration(
                  label: Text("Add a task for today",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(fontSizeFactor: 1.4)),
                  border: InputBorder.none),
            )
          ],
        ),
      ),
    );
  }
}

class PriorityCheckBox extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final GestureTapCallback onTap;

  const PriorityCheckBox(
      {super.key,
      required this.label,
      required this.color,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border:
              Border.all(width: 2, color: secondaryTextColor.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(label),
            ),
            Positioned(
                right: 4,
                bottom: 0,
                top: 0,
                child: Center(
                  child: _PriorityCheckBoxShape(
                    value: isSelected,
                    color: color,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class _PriorityCheckBoxShape extends StatelessWidget {
  final bool value;
  final Color color;
  const _PriorityCheckBoxShape(
      {super.key, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: value
            ? Icon(
                size: 16,
                CupertinoIcons.check_mark,
                color: themeData.colorScheme.onPrimary)
            : null);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zybra_task_app/src/theme/app_theme.dart';

import '../models/task.dart';
import '../providers/selected_task_provider.dart';
import '../providers/task_provider.dart';
import '../services/notifcation_service.dart';

class AddEditTaskView extends ConsumerStatefulWidget {
  const AddEditTaskView({
    super.key,
    this.task,
  });

  final Task? task;

  @override
  ConsumerState<AddEditTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends ConsumerState<AddEditTaskView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  late bool _isPriority;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? "");
    _isCompleted = widget.task?.isCompleted ?? false;
    _isPriority = widget.task?.isPriority ?? false;
    _reminderTime = widget.task?.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final taskId = widget.task?.id ?? DateTime.now().millisecondsSinceEpoch;
    final notificationId = taskId.hashCode & 0x7FFFFFFF;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final createdAt = widget.task?.createdAt ?? DateTime.now();
    final updatedAt = DateTime.now();

    final task = Task(
      id: taskId,
      title: title,
      description: description,
      isCompleted: _isCompleted,
      isPriority: _isPriority,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reminderTime: _reminderTime,
    );

    if (widget.task == null) {
      ref.read(taskProvider.notifier).addTask(task);
    } else {
      ref.read(taskProvider.notifier).updateTask(task);
    }

    // Handle task reminder notification
    if (_reminderTime != null) {
      NotificationService.scheduleNotification(
        id: notificationId,
        title: 'Task Reminder',
        body: title,
        scheduledTime: _reminderTime!,
      );
    }
  }

  void _deleteTask() {
    if (widget.task != null) {
      final notificationId = widget.task!.id.hashCode & 0x7FFFFFFF;
      NotificationService.cancelNotification(notificationId);
      ref.read(taskProvider.notifier).deleteTask(widget.task!.id!);
    }
  }

  void _setReminder() async {
    await NotificationService.requestExactAlarmPermission();
    DateTime? picked = await DatePicker.showDateTimePicker(
      context,
      minTime: DateTime.now(),
      currentTime: _reminderTime ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isWideScreen =
          constraints.maxWidth > 600; // Adjust width for tablets
      return Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        backgroundColor: AppTheme.scaffoldColor(context),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.scaffoldColor(context),
          title: widget.task == null
              ? const Text('Add New Task')
              : const Text('Edit Task'),
          actions: [
            widget.task == null
                ? const SizedBox()
                : IconButton(
                    icon: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.redAccent.withOpacity(0.27),
                      child: const Icon(
                        Icons.delete,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Task'),
                          content: const Text(
                              'Are you sure you want to delete this task?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        _deleteTask();
                        if (widget.task == null && context.mounted) {
                          print("Go back task null");
                          Navigator.pop(context);
                        } else if (MediaQuery.of(context).size.width < 600) {
                          print(
                              "Go back !isWideScreen ${(MediaQuery.of(context).size.width)}");
                          Navigator.pop(context);
                        } else {
                          ref.read(selectedTaskProvider.notifier).state = null;
                        }
                      }
                    },
                  ),
            IconButton(
              onPressed: () {
                _saveTask();
                if (widget.task == null) {
                  print("Go back task null");
                  Navigator.pop(context);
                } else if (MediaQuery.of(context).size.width < 600) {
                  print(
                      "Go back !isWideScreen ${(MediaQuery.of(context).size.width)}");
                  Navigator.pop(context);
                } else {
                  ref.read(selectedTaskProvider.notifier).state = null;
                }
              },
              icon: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.36),
                radius: 14,
                child: const Icon(
                  Icons.done,
                  size: 14,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(
              width: 18,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.grey)),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    textAlign: TextAlign.start,
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Mark as Completed:'),
                    Switch(
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Mark as Priority:'),
                    Switch(
                      value: _isPriority,
                      onChanged: (value) {
                        setState(() {
                          _isPriority = value;
                        });
                      },
                    ),
                  ],
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_reminderTime == null
                      ? 'Set Reminder'
                      : 'Reminder: ${DateFormat.yMd().add_jm().format(_reminderTime!)}'),
                  trailing: const Icon(Icons.alarm),
                  onTap: _setReminder,
                ),
                const SizedBox(
                  height: 36,
                )
              ],
            ),
          ),
        ),
        // floatingActionButtonLocation:
        //     isWideScreen ? null : FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: isWideScreen
        //     ? null
        //     : Padding(
        //         padding: const EdgeInsets.all(18.0),
        //         child: SizedBox(
        //           width: double.infinity,
        //           child: MaterialButton(
        //             elevation: 0,
        //             padding: const EdgeInsets.all(12),
        //             color: AppTheme.pendingCardColor,
        //             shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(9)),
        //             onPressed: _saveTask,
        //             child: Text(
        //               'Save Task',
        //               style: GoogleFonts.poppins(
        //                   color: AppTheme.titleColor(context)),
        //             ),
        //           ),
        //         ),
        //       ),
      );
    });
  }
}

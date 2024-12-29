import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../viewmodels/task_viewmodel.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final TaskViewModel _viewModel = TaskViewModel();

  TaskNotifier() : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final tasks = await _viewModel.getTasks();
    state = tasks;
  }

  Future<void> addTask(Task task) async {
    await _viewModel.addTask(task);
    loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _viewModel.updateTask(task);
    loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _viewModel.deleteTask(id);
    loadTasks();
  }
}

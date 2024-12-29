import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';

class SelectedTaskNotifier extends StateNotifier<Task?> {
  SelectedTaskNotifier() : super(null);

  void updateSelectedTask(Task? task) {
    if (state == task) {
      state = null; // Reset state
    }
    state = task; // Assign the new task
  }
}

final selectedTaskProvider = StateNotifierProvider<SelectedTaskNotifier, Task?>(
    (ref) => SelectedTaskNotifier());

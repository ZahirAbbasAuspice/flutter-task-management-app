
import '../models/task.dart';
import '../services/db_helper.dart';

class TaskViewModel {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<List<Task>> getTasks() async {
    final data = await _dbHelper.getTasks();
    return data.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> addTask(Task task) async {
    final newTask = task.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _dbHelper.insertTask(newTask.toMap());
  }

  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _dbHelper.updateTask(updatedTask.toMap());
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
  }
}

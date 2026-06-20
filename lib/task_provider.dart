import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_model.dart';
import 'firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// All tasks stream
final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).getTasks(uid);
});

// Filtered providers
final todayTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider).value?? [];
  final now = DateTime.now();
  return tasks.where((task) {
    if (task.isCompleted || task.dueDate == null)return false;
    final due = task.dueDate!;
    return due.year == now.year &&
    due.month == now.month &&
    due.day == now.day;
  }).toList();
});

final completedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider).value?? [];
  return tasks.where((task) => task.isCompleted).toList();
});
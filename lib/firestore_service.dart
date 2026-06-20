import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get tasks stream for current user
  Stream<List<TaskModel>> getTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => TaskModel.fromMap(doc))
            .toList());
  }

  // Add task
  Future<void> addTask(String uid, TaskModel task) async {
  final docRef =  await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add(task.toMap());

    // notify
    final newTask = task.copyWith(id: docRef.id);
    await NotificationService().scheduleTaskReminder(newTask);
  }


  // Update task
  Future<void> updateTask(String uid, TaskModel task) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.copyWith(updatedAt: DateTime.now()).toMap());
    //reschedule notifi
    await NotificationService().cancelTaskReminder(task.id);
    await NotificationService().scheduleTaskReminder(task);
  }

  // Delete task
  Future<void> deleteTask(String uid, String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
    //cancel it
    await NotificationService().cancelTaskReminder(taskId);
  }

  // Toggle complete
  Future<void> toggleTaskComplete(String uid, TaskModel task) async {
    final newStatus = !task.isCompleted;
    await updateTask(uid, task.copyWith(
        isCompleted: newStatus,
        updatedAt:  DateTime.now(),
    ));
    //cancel if completed
    if (newStatus){
    await NotificationService().cancelTaskReminder(task.id);
    }
  }
}
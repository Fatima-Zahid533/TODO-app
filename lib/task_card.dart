import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';
import 'auth_provider.dart';
import 'task_provider.dart';

class TaskCard extends ConsumerWidget {
  final TaskModel task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value!.uid;
    final firestore = ref.watch(firestoreServiceProvider);

    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => firestore.toggleTaskComplete(uid, task),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: task.isCompleted? Icons.undo : Icons.check,
            label: task.isCompleted? 'Undo' : 'Done',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => firestore.deleteTask(uid, task.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(task.priority.colorValue).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: ListTile(
          leading: Icon(
            task.isCompleted? Icons.check_circle : Icons.circle_outlined,
            color: Color(task.priority.colorValue),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${task.category} • ${task.dueDate != null? DateFormat('MMM dd').format(task.dueDate!) : 'No due date'}',
          ),
          trailing: Chip(
            label: Text(task.priorityText, style: const TextStyle(fontSize: 12)),
            backgroundColor: Color(task.priority.colorValue).withOpacity(0.2),
            side: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
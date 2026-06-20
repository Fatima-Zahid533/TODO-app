import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }
enum TaskCategory { work, personal, study, custom }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate, // Changed: removed 'required'
    required this.priority,
    required this.category,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id?? this.id,
      title: title?? this.title,
      description: description?? this.description,
      dueDate: dueDate?? this.dueDate,
      priority: priority?? this.priority,
      category: category?? this.category,
      isCompleted: isCompleted?? this.isCompleted,
      createdAt: createdAt?? this.createdAt,
      updatedAt: updatedAt?? this.updatedAt,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate!= null? Timestamp.fromDate(dueDate!) : null, // Changed: added null check
      'priority': priority.name,
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore doc
  factory TaskModel.fromMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskModel(
      id: doc.id,
      title: data['title']?? '',
      description: data['description']?? '',
      dueDate: data['dueDate']!= null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: data['category']?? 'personal',
      isCompleted: data['isCompleted']?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // For UI display
  String get priorityText =>
      priority.name[0].toUpperCase() + priority.name.substring(1);
}

extension TaskPriorityColor on TaskPriority {
  int get colorValue {
    switch (this) {
      case TaskPriority.low:
        return 0xFF4CAF50;
      case TaskPriority.medium:
        return 0xFFFF9800;
      case TaskPriority.high:
        return 0xFFF44336;
    }
  }
}
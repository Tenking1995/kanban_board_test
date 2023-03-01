import 'package:flutter/material.dart';
import 'kanban_task.dart';

class KanbanColumn {
  final String title;
  final List<KanbanTask> tasks;
  final Color color;

  KanbanColumn({
    required this.title,
    required this.color,
    List<KanbanTask>? tasks,
  }) : tasks = tasks ?? [];

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> tasksJson = tasks.map((task) => task.toJson()).toList();
    return {'title': title, 'tasks': tasksJson, 'color': '#${color.value.toRadixString(16).substring(2)}'};
  }

  factory KanbanColumn.fromJson(Map<String, dynamic> json) {
    var taskList = json['tasks'] as List;
    List<KanbanTask> tasks = taskList.map((taskJson) => KanbanTask.fromJson(taskJson)).toList();
    return KanbanColumn(
      title: json['title'],
      tasks: tasks,
      color: Color(int.parse(json['color'].substring(1, 7), radix: 16) + 0xFF000000),
    );
  }
}

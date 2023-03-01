import 'kanban_column.dart';

class KanbanBoard {
  final String title;
  final String description;
  final List<KanbanColumn> columns;

  KanbanBoard({
    required this.title,
    required this.description,
    required this.columns,
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> columnsTask = columns.map((task) => task.toJson()).toList();
    return {'title': title, 'description': description, 'columns': columnsTask};
  }

  factory KanbanBoard.fromJson(Map<String, dynamic> json) {
    var columns = json['columns'] as List;
    List<KanbanColumn> columnList = columns.map((columnJson) => KanbanColumn.fromJson(columnJson)).toList();
    return KanbanBoard(
      title: json['title'],
      description: json['description'],
      columns: columnList,
    );
  }
}

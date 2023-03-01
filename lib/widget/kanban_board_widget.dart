import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kanban_board/widget/kanban_column_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/kanban_board.dart';
import '../model/kanban_column.dart';
import '../model/kanban_task.dart';

class KanbanBoardWidget extends StatefulWidget {
  const KanbanBoardWidget({Key? key}) : super(key: key);

  @override
  _KanbanBoardWidgetState createState() => _KanbanBoardWidgetState();
}

class _KanbanBoardWidgetState extends State<KanbanBoardWidget> {
  KanbanBoard? board;

  @override
  void initState() {
    getKanbanBoardFromPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              board?.title ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              board?.description ?? '',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => _showAddColumnDialog(context),
              icon: const Icon(Icons.add_rounded),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (board?.columns != null)
                  for (var column in board!.columns)
                    KanbanColumnWidget(
                      column: column,
                      onEditTask: _handleEditTask,
                      onDeleteTask: _handleDeleteTask,
                      onMoveTask: _handleMoveTask,
                      onDeleteColumn: _deleteColumn,
                      onStoreData: saveKanbanBoardToPrefs,
                      key: Key(column.title),
                    ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _deleteColumn(KanbanColumn column) {
    setState(() {
      board?.columns.remove(column);
    });
    saveKanbanBoardToPrefs();
  }

  void _handleEditTask(KanbanTask task) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = task.title;
        String description = task.description;
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Title"),
                onChanged: (value) {
                  title = value;
                },
                controller: TextEditingController(text: task.title),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(hintText: "Description"),
                onChanged: (value) {
                  description = value;
                },
                controller: TextEditingController(text: task.description),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  "title": title,
                  "description": description,
                });
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        task.title = result["title"];
        task.description = result["description"];
      });
      saveKanbanBoardToPrefs();
    }
  }

  void _handleDeleteTask(KanbanTask task) {
    setState(() {
      if (board?.columns != null) {
        for (var column in board!.columns) {
          if (column.tasks.contains(task)) {
            column.tasks.remove(task);
            break;
          }
        }
      }
    });
    saveKanbanBoardToPrefs();
  }

  void _handleMoveTask(KanbanTask task, KanbanColumn toColumn) {
    setState(() {
      if (board?.columns != null) {
        for (var column in board!.columns) {
          if (column.tasks.contains(task)) {
            column.tasks.remove(task);
            break;
          }
        }
      }
      toColumn.tasks.add(task);
      saveKanbanBoardToPrefs();
    });
    // _saveBoardToSharedPreferences();
  }

  // Store KanbanBoard object in shared preferences
  Future<void> saveKanbanBoardToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'board';

    // Convert KanbanBoard object to JSON string
    final boardJson = jsonEncode(board?.toJson());

    // Store JSON string in shared preferences
    await prefs.setString(key, boardJson);
  }

  // Retrieve KanbanBoard object from shared preferences
  Future<void> getKanbanBoardFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'board';

    // Retrieve JSON string from shared preferences
    final boardJson = prefs.getString(key);

    if (boardJson != null) {
      // Convert JSON string to KanbanBoard object
      final boardMap = jsonDecode(boardJson) as Map<String, dynamic>;
      final mBoard = KanbanBoard.fromJson(boardMap);
      board = mBoard;
    } else {
      board = KanbanBoard(
        title: "Kanban Board",
        description: "Welcome and try",
        columns: [KanbanColumn(title: "To Do", color: Colors.blue)],
      );
    }

    setState(() {});
  }

  void _showAddColumnDialog(BuildContext mContext) {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: mContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter column title',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                String title = titleController.text;
                board?.columns.add(KanbanColumn(title: title, color: getRandomColor(), tasks: []));
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Color getRandomColor() {
    Random random = Random();
    int r = random.nextInt(256); // generate a random value between 0 and 255 for the red component
    int g = random.nextInt(256); // generate a random value between 0 and 255 for the green component
    int b = random.nextInt(256); // generate a random value between 0 and 255 for the blue component
    return Color.fromARGB(255, r, g, b); // create and return the color
  }
}

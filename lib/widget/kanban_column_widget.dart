import 'package:flutter/material.dart';
import 'package:kanban_board/widget/kanban_task_widget.dart';

import '../model/kanban_column.dart';
import '../model/kanban_task.dart';

class KanbanColumnWidget extends StatefulWidget {
  final KanbanColumn column;
  final Function(KanbanTask) onEditTask;
  final Function(KanbanTask) onDeleteTask;
  final Function(KanbanTask, KanbanColumn) onMoveTask;
  final Function(KanbanColumn) onDeleteColumn;
  final VoidCallback onStoreData;

  const KanbanColumnWidget({
    Key? key,
    required this.column,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onMoveTask,
    required this.onDeleteColumn,
    required this.onStoreData,
  }) : super(key: key);

  @override
  _KanbanColumnWidgetState createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(),
      child: DragTarget<KanbanTask>(
          onWillAccept: (task) => true,
          onAccept: (task) {
            setState(() {
              widget.onDeleteTask(task);
              widget.column.tasks.add(task);
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              // width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: widget.column.color,
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.column.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(),
                        icon: const Icon(
                          Icons.remove_circle,
                        ),
                      )
                    ],
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.grey,
                    onPressed: () => _showAddTaskDialog(context, widget.column),
                    child: const Icon(
                      Icons.add,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    direction: Axis.vertical,
                    children: [
                      ...widget.column.tasks.map((task) {
                        return LongPressDraggable(
                          data: task,
                          feedback: Container(
                            width: 200,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: Center(
                              child: Text(
                                task.title,
                                style: const TextStyle(fontSize: 20, color: Colors.black),
                              ),
                            ),
                          ),
                          child: KanbanTaskWidget(
                            task: task,
                            onTap: () => widget.onEditTask(task),
                            key: Key(task.title),
                            onDeleteTask: () => widget.onDeleteTask(task),
                            onEditTask: () {},
                          ),
                        );
                      }),
                    ],
                  ),

                  // ...widget.column.tasks.map((task) {
                  //   return KanbanTaskWidget(
                  //     task: task,
                  //     onTap: () => widget.onEditTask(task),
                  //     key: Key(task.title),
                  //     onDeleteTask: () {},
                  //     onEditTask: () {},
                  //   );
                  // }),
                ],
              ),
            );
          }),
    );
  }

  void _showAddTaskDialog(BuildContext mContext, KanbanColumn column) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: mContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
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
                String description = descriptionController.text;

                KanbanTask task = KanbanTask(
                    title: title, description: description, createdDate: DateTime.now(), duration: Duration.zero);
                column.tasks.add(task);

                // _saveTasksToPrefs();

                setState(() {});
                widget.onStoreData();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this column?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm) {
      widget.onDeleteColumn(widget.column); // call onDeleteColumn if confirmed
      widget.onStoreData();
    }
  }
}

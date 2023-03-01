import 'package:flutter/material.dart';

import '../model/kanban_task.dart';
import 'timer_widget.dart';

class KanbanTaskWidget extends StatelessWidget {
  final KanbanTask task;
  final Function onTap;
  final VoidCallback onEditTask;
  final VoidCallback onDeleteTask;
  final Key key;

  const KanbanTaskWidget({
    required this.key,
    required this.task,
    required this.onTap,
    required this.onEditTask,
    required this.onDeleteTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: GestureDetector(
        child: Wrap(
          direction: Axis.vertical,
          children: [
            SizedBox(
              child: Card(
                elevation: 2.0,
                // margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          task.description,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        TimerWidget(
                          task: task,
                          onCompleteTask: onDeleteTask,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

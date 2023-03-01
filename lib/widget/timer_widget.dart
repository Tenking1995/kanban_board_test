import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kanban_board/model/kanban_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/kanban_board.dart';

class TimerWidget extends StatefulWidget {
  final KanbanTask task;
  final VoidCallback onCompleteTask;
  const TimerWidget({Key? key, required this.task, required this.onCompleteTask}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Time: ${_formatElapsedTime()}'),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: _startTimer,
              child: Text(widget.task.isRunning ? 'Stop' : 'Start'),
            ),
            // const SizedBox(width: 5),
            // ElevatedButton(
            //   onPressed: _stopTimer,
            //   child: const Text('Stop'),
            // ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: _completeTimer,
              child: const Text('Complete'),
            ),
            const SizedBox(width: 5),
          ],
        ),
      ],
    );
  }

  void _startTimer() {
    widget.task.startDate = DateTime.now();
    widget.task.isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        widget.task.duration = (widget.task.duration ?? Duration.zero) + const Duration(seconds: 1);
      });
    });
  }

  // void _stopTimer() {
  //   widget.task.endDate = DateTime.now();
  //   _timer?.cancel();
  // }

  void _completeTimer() {
    setState(() {
      widget.task.isRunning = false;
      widget.task.endDate = DateTime.now();
      _timer?.cancel();
      _saveBoardToSharedPreferences(widget.task);
      widget.onCompleteTask();
    });
  }

  void _saveBoardToSharedPreferences(KanbanTask task) async {
    final prefs = await SharedPreferences.getInstance();
    List<KanbanTask> tasks = decodeTaskList(prefs.getStringList('tasks') ?? []);
    tasks.add(task);
    List<String> encodedTasks = tasks.map((mTtask) => jsonEncode(mTtask.toJson())).toList();
    prefs.setStringList('tasks', encodedTasks);
  }

  List<KanbanTask> decodeTaskList(List<String> encodedList) {
    List<KanbanTask> taskList = [];
    for (String encodedTask in encodedList) {
      Map<String, dynamic> jsonTask = json.decode(encodedTask);
      KanbanTask task = KanbanTask.fromJson(jsonTask);
      taskList.add(task);
    }
    return taskList;
  }

  String _formatElapsedTime() {
    int hours = widget.task.duration?.inHours ?? 0;
    int minutes = widget.task.duration?.inMinutes.remainder(60) ?? 0;
    int seconds = widget.task.duration?.inSeconds.remainder(60) ?? 0;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

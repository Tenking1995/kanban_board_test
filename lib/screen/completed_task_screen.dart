import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:file_picker/file_picker.dart';

import '../model/kanban_task.dart';

class CompletedTaskScreen extends StatefulWidget {
  const CompletedTaskScreen({Key? key}) : super(key: key);

  @override
  State<CompletedTaskScreen> createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> with WidgetsBindingObserver {
  List<KanbanTask> tasks = [];

  // @override
  // void initState() {
  //   // _getTasks();
  //   super.initState();
  //   WidgetsBinding.instance?.addObserver(this);
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance?.removeObserver(this);
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       _getTasks();
  //       break;
  //     case AppLifecycleState.inactive:
  //       break;
  //     case AppLifecycleState.paused:
  //       // went to Background
  //       break;
  //     case AppLifecycleState.detached:
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('CompletedTaskScreen'),
      onVisibilityChanged: (info) {
        // This callback will be called when the visibility changes
        if (info.visibleFraction == 1.0) {
          // Widget is fully visible
          setState(() {
            _getTasks();
          });
        } else {
          // Widget is partially visible or not visible
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _saveCsv,
            icon: const Icon(Icons.save),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    title: Text(tasks[index].title),
                    subtitle: Text('Completed on: ${_formatCompletedDateTime(tasks[index])}'),
                    trailing: Text('Time spent: ${_formatElapsedTime(tasks[index])}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompletedDateTime(KanbanTask task) {
    if (task.endDate != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
      final String formattedDate = formatter.format(task.endDate!);
      return formattedDate;
    }
    return '-';
  }

  String _formatElapsedTime(KanbanTask task) {
    int hours = task.duration?.inHours ?? 0;
    int minutes = task.duration?.inMinutes.remainder(60) ?? 0;
    int seconds = task.duration?.inSeconds.remainder(60) ?? 0;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _getTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myList = prefs.getStringList('tasks') ?? [];
    tasks = decodeTaskList(myList);
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

  void removeCompletedTasks() {
    removeValueFromSharedPreferences('tasks');
  }

  Future<void> removeValueFromSharedPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  Future<void> _saveCsv() async {
    List<List<dynamic>> rows = tasks.map((board) {
      return [board.title, board.description, board.createdDate, board.startDate, board.endDate, board.duration];
    }).toList();
    String csv = const ListToCsvConverter().convert(rows);

    const fileName = 'completed_tasks.csv';

    // Let the user choose the directory to save the file
    final directory = await FilePicker.platform.getDirectoryPath();

    // If no directory is chosen, return
    if (directory == null) return;

    // Create the file with the chosen directory and file name
    final file = File('$directory/$fileName');

    // Encode the CSV rows to a CSV string
    final csvString = rows.map((row) => row.join(',')).join('\n');

    // Write the CSV string to the file
    await file.writeAsString(csvString);
  }
}

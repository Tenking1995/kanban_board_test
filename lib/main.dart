import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kanban_board/screen/completed_task_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/kanban_board.dart';
import 'model/kanban_column.dart';
import 'model/kanban_task.dart';
import 'widget/kanban_board_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanban',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Kanban'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<KanbanList> kanbanList = [
  //   KanbanList(title: 'To Do', tasks: []),
  //   KanbanList(title: 'In Progress', tasks: []),
  //   KanbanList(title: 'Done', tasks: []),
  // ];

  // KanbanBoard board = KanbanBoard(
  //   title: "Welcome to Kanban Board",
  //   description: "Schedule your task now.",
  //   columns: [
  //     KanbanColumn(
  //       title: "To Do",
  //       color: Colors.blue,
  //       tasks: [],
  //     ),
  //   ],
  // );
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _items = [
      const SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: KanbanBoardWidget(),
        ),
      ),
      const SafeArea(
        child: CompletedTaskScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
        // actions: [IconButton(onPressed: () => _showAddColumnDialog(context, board), icon: const Icon(Icons.add))],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _items,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        iconSize: 20,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 15,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 25),
        selectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedIconTheme: const IconThemeData(
          color: Colors.black,
        ),
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex, //New
        onTap: (index) async {
          _selectedIndex = index;
          setState(() {});
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/calendar_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today")),
      body: Column(
        children: const [
          CalendarHeader(),
          Expanded(
            child: Center(
              child: Text("Tasks will appear here"),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Criar tarefa rápida
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
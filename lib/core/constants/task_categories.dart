import 'package:flutter/material.dart';

class TaskCategory {
  final String name;
  final Color color;

  const TaskCategory(this.name, this.color);
}

const List<TaskCategory> taskCategories = [
  TaskCategory("General", Colors.grey),
  TaskCategory("Work", Color(0xFF1E88E5)),
  TaskCategory("Study", Color(0xFF8E24AA)),
  TaskCategory("Health", Color(0xFF43A047)),
  TaskCategory("Fitness", Color(0xFF00ACC1)),
  TaskCategory("Finance", Color(0xFFF4511E)),
  TaskCategory("Family", Color(0xFFD81B60)),
  TaskCategory("Spiritual", Color(0xFF6D4C41)),
  TaskCategory("Projects", Color(0xFF3949AB)),
  TaskCategory("Reading", Color(0xFF7CB342)),
  TaskCategory("Business", Color(0xFF546E7A)),
  TaskCategory("Personal", Color(0xFFEC407A)),
  TaskCategory("Travel", Color(0xFF00897B)),
  TaskCategory("Learning", Color(0xFF5E35B1)),
  TaskCategory("Coding", Color(0xFF039BE5)),
  TaskCategory("Creative", Color(0xFFFF7043)),
  TaskCategory("Social", Color(0xFF26A69A)),
  TaskCategory("Mindset", Color(0xFF9CCC65)),
];
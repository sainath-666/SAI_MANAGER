import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;
  final String category;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.category,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final startSplit = (json['startTime'] as String).split(':');
    final endSplit = (json['endTime'] as String).split(':');
    
    final colorHex = json['colorHex'] as String;
    final hexClean = colorHex.replaceFirst('#', '');
    final parsedInt = int.parse(hexClean, radix: 16);
    final colorVal = hexClean.length == 6 ? parsedInt + 0xFF000000 : parsedInt;

    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: int.parse(startSplit[0]),
        minute: int.parse(startSplit[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endSplit[0]),
        minute: int.parse(endSplit[1]),
      ),
      color: Color(colorVal),
      category: json['category'] as String? ?? 'General',
    );
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
    String? category,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      category: category ?? this.category,
    );
  }
}

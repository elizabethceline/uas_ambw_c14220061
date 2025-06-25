import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/mood.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = Provider.of<SupabaseService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: user == null
          ? const Center(child: Text('User not found. Please log in again.'))
          : StreamBuilder<List<Mood>>(
              stream: supabaseService.getMoodHistory(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade700,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('An error occurred: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No mood history found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final moodEntries = snapshot.data!;
                return MoodCalendar(moods: moodEntries);
              },
            ),
    );
  }
}

class MoodCalendar extends StatefulWidget {
  final List<Mood> moods;
  const MoodCalendar({required this.moods, super.key});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  late final ValueNotifier<List<Mood>> _selectedMoods;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final Map<DateTime, List<Mood>> _moodsByDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _moodsByDay = _groupMoodsByDay(widget.moods);
    _selectedMoods = ValueNotifier(_getMoodsForDay(_selectedDay!));
  }

  @override
  void didUpdateWidget(covariant MoodCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.moods != oldWidget.moods) {
      setState(() {
        _moodsByDay = _groupMoodsByDay(widget.moods);
        _selectedMoods.value = _getMoodsForDay(_selectedDay!);
      });
    }
  }

  @override
  void dispose() {
    _selectedMoods.dispose();
    super.dispose();
  }

  Map<DateTime, List<Mood>> _groupMoodsByDay(List<Mood> moods) {
    Map<DateTime, List<Mood>> data = {};
    for (var mood in moods) {
      DateTime date = DateTime.utc(
        mood.createdAt.year,
        mood.createdAt.month,
        mood.createdAt.day,
      );
      if (data[date] == null) {
        data[date] = [];
      }
      data[date]!.add(mood);
    }
    return data;
  }

  List<Mood> _getMoodsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _moodsByDay[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedMoods.value = _getMoodsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Mood>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          eventLoader: _getMoodsForDay,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue.shade200,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.orange.shade400,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: _buildEventsMarker(events),
                );
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8.0),
        const Divider(),
        Expanded(
          child: ValueListenableBuilder<List<Mood>>(
            valueListenable: _selectedMoods,
            builder: (context, value, _) {
              if (value.isEmpty) {
                return const Center(
                  child: Text(
                    "No moods recorded for this day.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final mood = value[index];

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Text(
                        mood.mood,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        mood.note ?? 'No note',
                        style: TextStyle(
                          fontStyle: mood.note == null
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: mood.note == null
                              ? Colors.black54
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('HH:mm').format(mood.createdAt)} ',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsMarker(List<dynamic> events) {
    final moodText = events.take(1).map((e) => (e as Mood).mood).join('');
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Text(moodText, style: const TextStyle(fontSize: 12)),
    );
  }
}

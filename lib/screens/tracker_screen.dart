import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  late Box<MeditationSession> _sessionsBox;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MeditationSessionAdapter());
    _sessionsBox = await Hive.openBox<MeditationSession>('meditation_sessions');
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _durationController.dispose();
    _sessionsBox.close();
    super.dispose();
  }

  void _addSession() {
    if (_selectedDay == null) return;

    final session = MeditationSession(
      date: _selectedDay!,
      duration: int.tryParse(_durationController.text) ?? 0,
      reflection: _reflectionController.text,
    );

    _sessionsBox.add(session);
    _reflectionController.clear();
    _durationController.clear();
    setState(() {});
  }

  List<MeditationSession> _getSessionsForDay(DateTime day) {
    return _sessionsBox.values
        .where((session) =>
            session.date.year == day.year &&
            session.date.month == day.month &&
            session.date.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Tracker'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getSessionsForDay,
          ),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reflectionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reflection',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addSession,
                    child: const Text('Add Session'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<MeditationSession>>(
                valueListenable: _sessionsBox.listenable(),
                builder: (context, box, _) {
                  final sessions = _getSessionsForDay(_selectedDay!);
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ListTile(
                        title: Text(
                            '${session.duration} minutes meditation'),
                        subtitle: session.reflection.isNotEmpty
                            ? Text(session.reflection)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final key = _sessionsBox.keys.firstWhere(
                              (key) => _sessionsBox.get(key) == session,
                            );
                            _sessionsBox.delete(key);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@HiveType(typeId: 0)
class MeditationSession {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int duration;

  @HiveField(2)
  final String reflection;

  MeditationSession({
    required this.date,
    required this.duration,
    required this.reflection,
  });
}

class MeditationSessionAdapter extends TypeAdapter<MeditationSession> {
  @override
  final int typeId = 0;

  @override
  MeditationSession read(BinaryReader reader) {
    return MeditationSession(
      date: DateTime.parse(reader.read()),
      duration: reader.read(),
      reflection: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MeditationSession obj) {
    writer.write(obj.date.toIso8601String());
    writer.write(obj.duration);
    writer.write(obj.reflection);
  }
} 
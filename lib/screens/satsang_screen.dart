import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SatsangScreen extends StatefulWidget {
  const SatsangScreen({super.key});

  @override
  State<SatsangScreen> createState() => _SatsangScreenState();
}

class _SatsangScreenState extends State<SatsangScreen> {
  late Box<SatsangEvent> _satsangBox;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SatsangEventAdapter());
    _satsangBox = await Hive.openBox<SatsangEvent>('satsang_events');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _satsangBox.close();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addSatsang() {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
      return;
    }

    final event = SatsangEvent(
      title: _titleController.text,
      location: _locationController.text,
      date: _selectedDate,
      time: _selectedTime,
      status: SatsangStatus.interested,
    );

    _satsangBox.add(event);
    _titleController.clear();
    _locationController.clear();
    setState(() {});
  }

  void _updateStatus(SatsangEvent event, SatsangStatus newStatus) {
    final key = _satsangBox.keys.firstWhere(
      (key) => _satsangBox.get(key) == event,
    );
    event.status = newStatus;
    _satsangBox.put(key, event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satsang Events'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectDate,
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectTime,
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addSatsang,
                  child: const Text('Add Satsang'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<SatsangEvent>>(
              valueListenable: _satsangBox.listenable(),
              builder: (context, box, _) {
                final events = box.values.toList()
                  ..sort((a, b) => a.date.compareTo(b.date));
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.location),
                            Text(
                              '${DateFormat('MMM d, yyyy').format(event.date)} at ${event.time.format(context)}',
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                event.status == SatsangStatus.joined
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: event.status == SatsangStatus.joined
                                    ? Colors.green
                                    : null,
                              ),
                              onPressed: () {
                                _updateStatus(
                                  event,
                                  event.status == SatsangStatus.joined
                                      ? SatsangStatus.interested
                                      : SatsangStatus.joined,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                final key = _satsangBox.keys.firstWhere(
                                  (key) => _satsangBox.get(key) == event,
                                );
                                _satsangBox.delete(key);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum SatsangStatus { interested, joined }

@HiveType(typeId: 1)
class SatsangEvent {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String location;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final TimeOfDay time;

  @HiveField(4)
  SatsangStatus status;

  SatsangEvent({
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
  });
}

class SatsangEventAdapter extends TypeAdapter<SatsangEvent> {
  @override
  final int typeId = 1;

  @override
  SatsangEvent read(BinaryReader reader) {
    return SatsangEvent(
      title: reader.read(),
      location: reader.read(),
      date: DateTime.parse(reader.read()),
      time: TimeOfDay(
        hour: reader.read(),
        minute: reader.read(),
      ),
      status: SatsangStatus.values[reader.read()],
    );
  }

  @override
  void write(BinaryWriter writer, SatsangEvent obj) {
    writer.write(obj.title);
    writer.write(obj.location);
    writer.write(obj.date.toIso8601String());
    writer.write(obj.time.hour);
    writer.write(obj.time.minute);
    writer.write(obj.status.index);
  }
} 
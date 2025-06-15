import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final List<Reminder> _reminders = [
    Reminder(
      id: 0,
      title: 'Morning Meditation',
      time: const TimeOfDay(hour: 6, minute: 0),
      isEnabled: false,
    ),
    Reminder(
      id: 1,
      title: 'Evening Cleaning',
      time: const TimeOfDay(hour: 18, minute: 0),
      isEnabled: false,
    ),
    Reminder(
      id: 2,
      title: '9 PM Prayer',
      time: const TimeOfDay(hour: 21, minute: 0),
      isEnabled: false,
    ),
    Reminder(
      id: 3,
      title: 'Night Meditation',
      time: const TimeOfDay(hour: 22, minute: 0),
      isEnabled: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      reminder.id,
      reminder.title,
      'Time for ${reminder.title.toLowerCase()}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meditation_reminders',
          'Meditation Reminders',
          channelDescription: 'Reminders for meditation and prayer times',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  void _toggleReminder(Reminder reminder) async {
    setState(() {
      reminder.isEnabled = !reminder.isEnabled;
    });

    if (reminder.isEnabled) {
      await _scheduleNotification(reminder);
    } else {
      await _cancelNotification(reminder.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return ListTile(
            title: Text(reminder.title),
            subtitle: Text(reminder.time.format(context)),
            trailing: Switch(
              value: reminder.isEnabled,
              onChanged: (value) => _toggleReminder(reminder),
            ),
          );
        },
      ),
    );
  }
}

class Reminder {
  final int id;
  final String title;
  final TimeOfDay time;
  bool isEnabled;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.isEnabled,
  });
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'timer_screen.dart';
import 'reminders_screen.dart';
import 'tracker_screen.dart';
import 'library_screen.dart';
import 'satsang_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation App'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: [
          NavigationDrawerDestination(
            icon: const Icon(Icons.timer),
            label: const Text('Timer'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.notifications),
            label: const Text('Reminders'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.track_changes),
            label: const Text('Tracker'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.menu_book),
            label: const Text('Library'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.people),
            label: const Text('Satsang'),
          ),
        ],
        onDestinationSelected: (index) {
          Navigator.pop(context);
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimerScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrackerScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LibraryScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SatsangScreen()),
              );
              break;
          }
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Daily Inspiration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '"Peace begins with a smile."',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- Mother Teresa',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
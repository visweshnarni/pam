import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<LibraryItem> _items = [
    LibraryItem(
      title: "Master's Messages",
      assetPath: 'assets/data/masters_messages.md',
    ),
    LibraryItem(
      title: 'Daily Thoughts',
      assetPath: 'assets/data/daily_thoughts.md',
    ),
    LibraryItem(
      title: 'Practice Guides',
      assetPath: 'assets/data/practice_guides.md',
    ),
  ];

  String _content = '';

  Future<void> _loadContent(String assetPath) async {
    try {
      final String content = await rootBundle.loadString(assetPath);
      setState(() {
        _content = content;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading content: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              _loadContent(_items[index].assetPath);
            },
            labelType: NavigationRailLabelType.all,
            destinations: _items.map((item) {
              return NavigationRailDestination(
                icon: const Icon(Icons.book),
                label: Text(item.title),
              );
            }).toList(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Markdown(
                data: _content,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  p: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryItem {
  final String title;
  final String assetPath;

  LibraryItem({
    required this.title,
    required this.assetPath,
  });
} 
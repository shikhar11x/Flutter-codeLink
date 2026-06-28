import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'editor_screen.dart';

void main() {
  runApp(const CodeLinkApp());
}

class CodeLinkApp extends StatelessWidget {
  const CodeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Random slug generator
  String _generateSlug() {
    const adjectives = [
      'swift', 'bright', 'cool', 'dark', 'fast',
      'wild', 'calm', 'bold', 'clean', 'sharp'
    ];
    const nouns = [
      'river', 'storm', 'pixel', 'forge', 'spark',
      'cloud', 'blade', 'wave', 'node', 'byte'
    ];

    final adj = adjectives[DateTime.now().millisecond % adjectives.length];
    final noun = nouns[DateTime.now().second % nouns.length];
    final number = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;

    return '$adj-$noun-$number';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo + title
            const Icon(Icons.link, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'CodeLink',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time collaborative code editor',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 48),

            // New Pad button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final slug = _generateSlug();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditorScreen(padSlug: slug),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'New Pad',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Open existing pad
            TextButton(
              onPressed: () {
                _showOpenPadDialog(context);
              },
              child: Text(
                'Open existing pad',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to open an existing pad by slug
  void _showOpenPadDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Open Pad',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter pad slug (e.g. swift-river-4829)',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF30363D)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
            ),
            onPressed: () {
              final slug = controller.text.trim();
              if (slug.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditorScreen(padSlug: slug),
                  ),
                );
              }
            },
            child: const Text('Open', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
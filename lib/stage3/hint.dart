import 'package:flutter/material.dart';
import '../hints/daily_hint_tile.dart';

class HintScreen extends StatelessWidget {
  const HintScreen({super.key});

  static const _hints = [
    ('Fragment 1', 'Tap the flower vase.'),
    (
      'Fragment 3',
      'Tap the arrow on the clock to point it at 3, then tap the clock again.',
    ),
    (
      'Computer Desk Cabinet',
      'Go to computer and solve the binary.\nThe answer is 10010.\nTo get the key for the computer desk cabinet',
    ),
    (
      'Fragment 4',
      'Cook the black object with water on the pot. and oven it.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _HintLayout(
      title: 'You can only use hint 2 times a day!',
      hints: _hints,
    );
  }
}

class _HintLayout extends StatelessWidget {
  final String title;
  final List<(String, String)> hints;

  const _HintLayout({required this.title, required this.hints});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color.fromARGB(235, 30, 22, 40),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'ShareTechMono',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              for (var i = 0; i < hints.length; i++)
                DailyHintTile(
                  id: 'stage3-$i',
                  number: i + 1,
                  title: hints[i].$1,
                  body: hints[i].$2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../hints/daily_hint_tile.dart';

class HintScreen extends StatelessWidget {
  const HintScreen({super.key});

  static const _hints = [
    ('Fragment 1', 'Turn off the light and go to the light bulb.'),
    (
      'Fragment 2',
      'Turn off the light and turn on the lamp on the computer desk.',
    ),
    (
      'Cabinet in the faucet 1',
      'Check the hint board and the surrounding area for clues.',
    ),
    ('Computer', 'The answer to the logic gate puzzle is 1011.'),
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
                  fontSize: 18,
                  fontFamily: 'ShareTechMono',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              for (var i = 0; i < hints.length; i++)
                DailyHintTile(
                  id: 'stage2-$i',
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

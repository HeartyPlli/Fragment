import 'package:flutter/material.dart';
import '../hints/daily_hint_tile.dart';

class HintScreen extends StatelessWidget {
  const HintScreen({super.key});

  static const _hints = [
    (
      'Fragment 1',
      'You can find the first fragment inside the sofa cushion.',
    ),
    (
      'Fragment 2',
      'Double tap mirror.',
    ),
    (
      'Cabinet in table 1',
      'Get the clues from frame 2, the oven, and cabinet 2.\nThe answer is an upside down triangle, circle, and square.',
    ),
    (
      'Cabinet in table 2',
      'Get the clues from the table by the sofa and the computer desk.\nMatch the two images to form an answer.',
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

  const _HintLayout({
    required this.title,
    required this.hints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),
          Center(
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
                      id: 'stage1-$i',
                      number: i + 1,
                      title: hints[i].$1,
                      body: hints[i].$2,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

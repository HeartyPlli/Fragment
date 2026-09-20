import 'package:flutter/material.dart';
import '../hints/daily_hint_tile.dart';

class HintScreen extends StatelessWidget {
  const HintScreen({super.key});

  static const _hints = [
    (
      'Matchbox 1',
      'Look at the surrounding area and find the shape with the same color.',
    ),
    (
      'Matchbox 2',
      'Get the clues from matchbox 1 and among the clothes.\nMatch the two images to form a number.',
    ),
    (
      'Matchbox 3',
      'Get the clues from the clothes, matchbox 1, and the surroundings.\nForm a word with the clues.',
    ),
    (
      'Matchbox 4',
      'Solve the fish and rat puzzle first to get the clue for the mushroom puzzle.\nThe clues can be found in matchbox 3 and from the fish and rat puzzle itself.',
    ),
    (
      'Exit',
      'First, solve the bottle cap puzzle and get the bowl lid to find a picture of a knife.\nNext, get the other knife picture from matchbox 4.\nCombine the two images and use the resulting knife to cut the bunny\'s face.',
    ),
  ];

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
              for (var i = 0; i < _hints.length; i++)
                DailyHintTile(
                  id: 'stage4-$i',
                  number: i + 1,
                  title: _hints[i].$1,
                  body: _hints[i].$2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

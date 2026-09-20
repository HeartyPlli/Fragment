import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class AchievementData {
  final String imagePath;
  final String lockedMessage;
  final String unlockedMessage;

  const AchievementData({
    required this.imagePath,
    required this.lockedMessage,
    required this.unlockedMessage,
  });
}

class AchievementsTabUI extends StatefulWidget {
  const AchievementsTabUI({super.key});

  static final ValueNotifier<List<bool>> unlocked =
      ValueNotifier<List<bool>>(List<bool>.filled(9, false));

  static void unlock(int index) {
    if (index < 0 || index >= unlocked.value.length) return;

    final next = List<bool>.from(unlocked.value);
    next[index] = true;
    unlocked.value = next;
  }

  @override
  State<AchievementsTabUI> createState() => _AchievementsTabUIState();
}

class _AchievementsTabUIState extends State<AchievementsTabUI> {
  static const List<AchievementData> _achievements = [
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement1.png',
      lockedMessage: 'Complete Lost Beginning',
      unlockedMessage: 'Peonies',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement2.png',
      lockedMessage: 'Complete Scattered Path',
      unlockedMessage: 'Lotus Flowers',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement3.png',
      lockedMessage: 'Complete Final Fragment',
      unlockedMessage: 'Mount Malindang',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement4.png',
      lockedMessage: 'Complete Lost Beginning without using hints.',
      unlockedMessage: 'Mirror',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement5.png',
      lockedMessage: 'Complete Scattered Path without using hints.',
      unlockedMessage: 'Flower Vase',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement6.png',
      lockedMessage: 'Complete Final Fragment without using hints.',
      unlockedMessage: 'Aria',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement7.png',
      lockedMessage: 'Play Afterfragment <Copper>',
      unlockedMessage: 'Fable',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement8.png',
      lockedMessage: 'Complete Afterfragment <Copper>',
      unlockedMessage: 'Puzzle Master',
    ),
    AchievementData(
      imagePath: 'assets/images/Achievement/achievement9.png',
      lockedMessage: 'Complete Afterfragment <Copper> without using hints.',
      unlockedMessage: 'Aria and Copper',
    ),
  ];

  Timer? _messageTimer;
  String _message = '';

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    _messageTimer?.cancel();
    setState(() => _message = message);
    _messageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _message = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Achievement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'SpecialElite',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 0),
        SizedBox(
          height: 25,
          width: 400,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _message.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    _message,
                    key: ValueKey(_message),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'ShareTechMono',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
        SizedBox(
          height: 210,
          width: 210,
          child: ValueListenableBuilder<List<bool>>(
            valueListenable: AchievementsTabUI.unlocked,
            builder: (context, unlocked, _) {
              return GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: List.generate(
                  _achievements.length,
                  (index) => _achievementTile(
                    data: _achievements[index],
                    isUnlocked: unlocked[index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _achievementTile({
    required AchievementData data,
    required bool isUnlocked,
  }) {
    return GestureDetector(
      onTap: () {
        _showMessage(isUnlocked ? data.unlockedMessage : data.lockedMessage);
      },
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              FadedAssetImage(
                data.imagePath,
                fit: BoxFit.contain,
              ),
              AnimatedOpacity(
                opacity: isUnlocked ? 0 : 1,
                duration: const Duration(milliseconds: 220),
                child: FadedAssetImage(
                  data.imagePath,
                  fit: BoxFit.contain,
                  color: Colors.black.withOpacity(0.96),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

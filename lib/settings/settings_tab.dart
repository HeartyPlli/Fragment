import 'package:flutter/material.dart';
import 'package:fragment/app_state.dart';
import 'package:fragment/audio/audio_controller.dart';
import 'package:fragment/stage1/stage1_room.dart';
import 'package:fragment/stage2/stage2_room.dart';
import 'package:fragment/stage3/stage3_room.dart';
import 'package:fragment/stage4/stage4_room.dart';
import 'package:fragment/reset_confirm/reset_confirm_dialog.dart';

class SettingsTabUI extends StatefulWidget {
  const SettingsTabUI({super.key});

  @override
  State<SettingsTabUI> createState() => _SettingsTabUIState();
}

class _SettingsTabUIState extends State<SettingsTabUI> {
  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
// -----------------------------------------------------------------
// Resent Button
// -----------------------------------------------------------------
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
            textStyle: const TextStyle(
              fontSize: 25,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            AudioController.instance.tap();
            final confirmed = await showResetConfirmDialog(
              context: context,
              title: 'Reset current level?',
              message:
                  'Progress for this stage will restart. You can’t undo this.',
              confirmLabel: 'Reset level',
              cancelLabel: 'Keep playing',
            );
            if (confirmed == true) {
              _clearStageSnapshot(appState.currentStage);
              await appState.resetCurrentLevel();
              if (!context.mounted) return;
              _restartCurrentStage(context, appState.currentStage);
            }
          },
          child: const Text(
            'Reset: Current Level',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
// -----------------------------------------------------------------
// Music Icon
// -----------------------------------------------------------------
            GestureDetector(
              onTap: () async {
                await playTap();
                await appState.setMusicOn(!appState.musicOn.value);
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: appState.musicOn,
                builder: (context, musicOn, _) => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: musicOn ? Colors.white : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: musicOn ? Colors.black : Colors.black54,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 35),
// -----------------------------------------------------------------
// Audio Icon
// -----------------------------------------------------------------
            GestureDetector(
              onTap: () async {
                await playTap();
                await appState.setSoundOn(!appState.soundOn.value);
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: appState.soundOn,
                builder: (context, soundOn, _) => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: soundOn ? Colors.white : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: soundOn ? Colors.black : Colors.black54,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 35),
// -----------------------------------------------------------------
// hint Icon
// -----------------------------------------------------------------

            GestureDetector(
              onTap: () async {
                await playTap();
                await appState.setHintOn(!appState.hintOn.value);
              },
              child: ValueListenableBuilder<bool>(
                valueListenable: appState.hintOn,
                builder: (context, hintOn, _) => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: hintOn ? Colors.white : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.visibility,
                    color: hintOn ? Colors.black : Colors.black54,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 35),
      ],
    );
  }

  void _restartCurrentStage(BuildContext context, int stage) {
    final Widget screen = switch (stage) {
      1 => const Stage1RoomScreen(),
      2 => const Stage2RoomScreen(),
      3 => const Stage3RoomScreen(),
      4 => const Stage4RoomScreen(),
      _ => const Stage1RoomScreen(),
    };
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  void _clearStageSnapshot(int stage) {
    switch (stage) {
      case 1:
        Stage1RoomScreen.clearSavedProgress(discardNextSave: true);
        break;
      case 2:
        Stage2RoomScreen.clearSavedProgress(discardNextSave: true);
        break;
      case 3:
        Stage3RoomScreen.clearSavedProgress(discardNextSave: true);
        break;
      case 4:
        Stage4RoomScreen.clearSavedProgress(discardNextSave: true);
        break;
    }
  }
}

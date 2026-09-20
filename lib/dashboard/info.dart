import 'package:flutter/material.dart';
import 'package:fragment/app_state.dart';
import 'package:fragment/audio/audio_controller.dart';
import 'package:fragment/intro_screen.dart';
import 'package:fragment/main.dart';
import 'package:fragment/background/video_background.dart';
import 'package:fragment/database/video_paths.dart';
import 'package:fragment/reset_confirm/reset_confirm_dialog.dart';
import 'package:fragment/stage1/stage1_room.dart';
import 'package:fragment/stage2/stage2_room.dart';
import 'package:fragment/stage3/stage3_room.dart';
import 'package:fragment/stage4/stage4_room.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AudioController.instance.playMusic(AppState.dashboardMusic);
    return Scaffold(
      backgroundColor: backgroundColor(),
      body: Stack(
        fit: StackFit.expand,
        children: [
// -----------------------------------------------------------------
// VIDEO BACKGROUND import
// -----------------------------------------------------------------
          const VideoBackground(
            assetPath: kDashboardVideo,
            opacity: 0.35,
          ),
// -----------------------------------------------------------------
// the overlay thingy
// -----------------------------------------------------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black26,
                ],
              ),
            ),
          ),

// -----------------------------------------------------------------
// Content
// -----------------------------------------------------------------
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x661E1628),
                  borderRadius: BorderRadius.circular(46),
                  border: Border.all(
                      color: const Color.fromARGB(43, 255, 255, 255), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(34, 197, 136, 255)
                          .withOpacity(0.15),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to Fragment.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'SpecialElite',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'This game is about a broken world. The world is split into many small pieces called fragments. '
                      'You will explore these pieces and try to understand what happened.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'ShareTechMono',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'As you play, you will find secrets, new places, and different challenges. '
                      'Each step will help you learn more about the world.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'ShareTechMono',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Thank you for playing Fragment. Good luck on finding all achievements.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'ShareTechMono',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 19),
// -----------------------------------------------------------------
// Reset Button
// -----------------------------------------------------------------
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        AudioController.instance.tap();
                        final confirmed = await showResetConfirmDialog(
                          context: context,
                          title: 'Reset All Progress?',
                          message:
                              'Everything you have unlocked will be cleared. Are you sure?',
                          confirmLabel: 'Reset all',
                          cancelLabel: 'Cancel',
                        );
                        if (confirmed == true) {
                          Stage1RoomScreen.clearSavedProgress();
                          Stage2RoomScreen.clearSavedProgress();
                          Stage3RoomScreen.clearSavedProgress();
                          Stage4RoomScreen.clearSavedProgress();
                          await AppState.instance.resetAll();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const IntroScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        'Reset: All',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'ShareTechMono',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
// -----------------------------------------------------------------
// Back Button
// -----------------------------------------------------------------
                    IconButton(
                      iconSize: 30,
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: withTap(() {
                        Navigator.of(context).pop();
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_state.dart';
import 'audio/audio_controller.dart';
import 'package:fragment/background/video_background.dart';
import 'package:fragment/database/video_paths.dart';
import 'package:fragment/settings/achievements_tab.dart';
import 'stage1/stage1_room.dart';
import 'stage2/stage2_room.dart';
import 'stage3/stage3_room.dart';
import 'stage4/stage4_room.dart';
import 'main.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

/// Very light “level picker” screen.
/// Pass `progress` to control which tiles show an image:
/// 1 = only stage 1 image, 2 = stage 1 + stage 2 image, 3 = all three,
/// 4 = final: stage 1, stage 2, and stage 3 uses the “final” image.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key, this.progress});

  final int? progress; // 1..5

  @override
  Widget build(BuildContext context) {
    AudioController.instance.playMusic(AppState.dashboardMusic);
    return ValueListenableBuilder<int>(
      valueListenable: AppState.instance.maxStage,
      builder: (context, savedProgress, _) {
        final effectiveProgress = (progress ?? savedProgress).clamp(1, 5);
        final stageImages = _imagesForProgress(effectiveProgress);

        return Scaffold(
          backgroundColor: backgroundColor(),
          body: Stack(
            fit: StackFit.expand,
            children: [
// -------------------------------------------------------------------------
//  VIDEO BACKGROUND Import
// -------------------------------------------------------------------------
              const VideoBackground(
                assetPath: kDashboardVideo,
                opacity: 0.35,
              ),
// -------------------------------------------------------------------------
//  para layout
// -------------------------------------------------------------------------
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: withTap(() {
                          Navigator.of(context).pop();
                        }),
                      ),

                      const SizedBox(height: 15),
// -------------------------------------------------------------------------
//  Text
// -------------------------------------------------------------------------

                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 50),
                        child: Text(
                          'Pick your level :',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'SpecialElite',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

// -------------------------------------------------------------------------
//  Text under box
// -------------------------------------------------------------------------

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _levelTile(
                            context,
                            label: 'Lost Beginning',
                            imagePath: stageImages[0],
                            onTap: () {
                              _openStage(
                                context,
                                const Stage1RoomScreen(),
                                achievementIndex: 0,
                              );
                            },
                          ),
                          _levelTile(
                            context,
                            label: 'Scattered Path',
                            imagePath: stageImages[1],
                            onTap: () {
                              _openStage(
                                context,
                                const Stage2RoomScreen(),
                                achievementIndex: 1,
                              );
                            },
                          ),
                          _levelTile(
                            context,
                            label: 'Final Fragment',
                            imagePath: stageImages[2],
                            onTap: () {
                              _openStage(
                                context,
                                const Stage3RoomScreen(),
                                achievementIndex: 2,
                              );
                            },
                          ),
                          _levelTile(
                            context,
                            label: 'Afterfragment <Copper>',
                            imagePath: stageImages[3],
                            onTap: () {
                              _openStage(
                                context,
                                const Stage4RoomScreen(),
                                achievementIndex: 3,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openStage(
    BuildContext context,
    Widget screen, {
    required int achievementIndex,
  }) {
    AudioController.instance.tap();
    AchievementsTabUI.unlock(achievementIndex);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

// -------------------------------------------------------------------------
//  Considation
// -------------------------------------------------------------------------

  List<String?> _imagesForProgress(int p) {
    const stage1 = 'assets/images/start (1).png';
    const stage1Cleared = 'assets/images/stage1.png';
    const stage2 = 'assets/images/stage2.png';
    const stage2Cleared = 'assets/images/stage2_cleared.png';
    const stage3 = 'assets/images/stage3.png';
    const stage3Final = 'assets/images/stage3_final.png';
    const stage4 = 'assets/images/Copper/Stage4.jpg';
    const stage4Final = 'assets/images/Copper/Stage4_Final.jpg';

    switch (p) {
      case 1:
        return [stage1, null, null, null];
      case 2:
        return [stage1Cleared, stage2, null, null];
      case 3:
        return [stage1Cleared, stage2Cleared, stage3, null];
      case 4:
        return [stage1Cleared, stage2Cleared, stage3Final, stage4];
      case 5:
      default:
        return [stage1Cleared, stage2Cleared, stage3Final, stage4Final];
    }
  }

// -------------------------------------------------------------------------
//  Box design
// -------------------------------------------------------------------------
  Widget _levelTile(
    BuildContext context, {
    required String label,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final border = Border.all(
      color: const Color.fromARGB(255, 240, 234, 234),
      width: 2,
    );
    final radius = BorderRadius.circular(22);
    return Column(
      children: [
        GestureDetector(
          onTap: imagePath == null ? null : onTap,
          child: Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: border,
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.35),
            ),
            clipBehavior: Clip.antiAlias,
            child: imagePath != null
                ? FadedAssetImage(imagePath, fit: BoxFit.cover)
                : null,
          ),
        ),

        const SizedBox(height: 15),
// -------------------------------------------------------------------------
//  Text under box design
// -------------------------------------------------------------------------
        SizedBox(
          width: 130,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'ShareTechMono',
            ),
          ),
        ),
      ],
    );
  }
}

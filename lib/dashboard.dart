import 'package:flutter/material.dart';
import 'app_state.dart';
import 'audio/audio_controller.dart';
import 'dashboard/info.dart';
import 'settings/setting.dart';
import 'main.dart';
import 'background/video_background.dart';
import 'database/video_paths.dart';
import 'start.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    AudioController.instance.playMusic(AppState.dashboardMusic);
    AppState.instance.setCurrentStage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(),
      body: SafeArea(
        child: Stack(
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
//  For the Info Button
// -------------------------------------------------------------------------

            Positioned(
              top: 5,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.info_outline,
                    color: Colors.white, size: 30),
                onPressed: withTap(() {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const InfoScreen(),
                      transitionDuration: const Duration(milliseconds: 800),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),

// -------------------------------------------------------------------------
// Settings Button
// -------------------------------------------------------------------------

            Positioned(
              top: 5,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                onPressed: withTap(() {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const SettingsScreen(),
                      transitionDuration: const Duration(milliseconds: 800),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
// -------------------------------------------------------------------------
// Logo
// -------------------------------------------------------------------------

            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FadedAssetImage(
                      'assets/images/NameGame.png',
                      width: 360,
                    ),

                    const SizedBox(height: 10),
// -------------------------------------------------------------------------
// Start Buttonf
// -------------------------------------------------------------------------
                    GestureDetector(
                      onTap: withTap(() {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const StartScreen(),
                            transitionDuration:
                                const Duration(milliseconds: 800),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                ),
                                child: child,
                              );
                            },
                          ),
                        );
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(0, 244, 67, 54),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 158, 32, 63),
                              blurRadius: 20,
                              spreadRadius: -15,
                            ),
                          ],
                          border: Border.all(
                            color: const Color.fromARGB(255, 122, 28, 28),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: 'ShareTechMono',
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

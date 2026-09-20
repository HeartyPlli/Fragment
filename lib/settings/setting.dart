import 'package:flutter/material.dart';
import 'package:fragment/app_state.dart';
import 'package:fragment/audio/audio_controller.dart';
import 'package:fragment/dashboard.dart';
import 'settings_tab.dart';
import 'how_to_tab.dart';
import 'achievements_tab.dart';
import 'bottom_nav.dart';
import '../background/video_background.dart';
import '../database/video_paths.dart';

enum SettingsTab { settings, howTo, achievements }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsTab _tab = SettingsTab.settings;

  @override
  void initState() {
    super.initState();
    AudioController.instance.playMusic(AppState.dashboardMusic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
// -----------------------------------------------------------------
// Background Looping Video Import
// -----------------------------------------------------------------
          const VideoBackground(
            assetPath: kDashboardVideo,
            opacity: 0.35,
          ),

// -----------------------------------------------------------------
// Home Button
// -----------------------------------------------------------------
          Positioned(
            top: 15,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 30),
              onPressed: withTap(() {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const DashboardScreen(),
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
                  (route) => false,
                );
              }),
            ),
          ),

// -----------------------------------------------------------------
// Back Button
// -----------------------------------------------------------------
          Positioned(
            top: 15,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: withTap(() {
                Navigator.of(context).pop();
              }),
            ),
          ),

// -----------------------------------------------------------------
//  Button Nav
// -----------------------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildContent(),
                ),
                BottomNav(
                  currentTab: _tab,
                  onChanged: (tab) {
                    setState(() {
                      _tab = tab;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// -----------------------------------------------------------------
// switch page
// -----------------------------------------------------------------
  Widget _buildContent() {
    switch (_tab) {
      case SettingsTab.settings:
        return const SettingsTabUI();
      case SettingsTab.howTo:
        return const HowToTabUI();
      case SettingsTab.achievements:
        return const AchievementsTabUI();
    }
  }
}

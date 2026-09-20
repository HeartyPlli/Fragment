import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'app_state.dart';
import 'dashboard.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

// --------------------------------------------------------
// Video for Intro
// --------------------------------------------------------

class _IntroScreenState extends State<IntroScreen> {
  late VideoPlayerController _ctrl;
  late Future<void> _initFuture;
  bool _skipIntro = false;
  bool _ctrlReady = false;

  @override
  void initState() {
    super.initState();
    if (AppState.instance.appIntroSeen) {
      _skipIntro = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToDashboard());
      return;
    }
    _ctrl = VideoPlayerController.asset('assets/videos/Intro.mp4');
    _ctrlReady = true;
    _initFuture = _load();
  }

  Future<void> _load() async {
    await _ctrl.initialize();
    if (!mounted) return;
    await _ctrl.setVolume(1);
    _ctrl.addListener(_checkEnd);
    await _ctrl.play();
  }

  void _checkEnd() {
    final v = _ctrl.value;
    if (v.isInitialized && v.position >= v.duration) {
      _ctrl.removeListener(_checkEnd);
      AppState.instance.setAppIntroSeen(true);
      _goToDashboard();
    }
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
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
    );
  }

// --------------------------------------------------------
// If video Intro doesn't load
// --------------------------------------------------------

  @override
  void dispose() {
    if (_ctrlReady) {
      _ctrl.removeListener(_checkEnd);
      _ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _skipIntro
          ? const SizedBox.shrink()
          : FutureBuilder(
              future: _initFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  );
                }

                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Could not load intro video.\n${snap.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

// --------------------------------------------------------
// The design for the video hehe
// --------------------------------------------------------

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxH = constraints.maxHeight;
                    final maxW = constraints.maxWidth;

                    final targetWidth = maxW * 0.8;
                    final targetHeight = maxH * 0.8;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: Colors.black),
                        Center(
                          child: SizedBox(
                            width: targetWidth,
                            height: targetHeight,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _ctrl.value.size.width,
                                height: _ctrl.value.size.height,
                                child: VideoPlayer(_ctrl),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}

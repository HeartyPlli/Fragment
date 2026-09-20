import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../start.dart';

class EndingIntroScreen extends StatefulWidget {
  const EndingIntroScreen({super.key});

  @override
  State<EndingIntroScreen> createState() => _EndingIntroScreenState();
}

class _EndingIntroScreenState extends State<EndingIntroScreen> {
  late final VideoPlayerController _ctrl;
  late final Future<void> _initFuture;
  int _dialogIndex = 0;
  bool _playing = false;

  static const _lines = [
    'You built these wall...',
    'You were never meant to escape...',
    '... but you did it..',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.asset('assets/videos/ending1.mp4');
    _initFuture = _ctrl.initialize().then((_) {
      if (!mounted) return;
      _ctrl.addListener(_checkEnd);
      setState(() {});
    });
  }

  void _next() {
    if (_playing) return;
    if (_dialogIndex < _lines.length - 1) {
      setState(() => _dialogIndex += 1);
      return;
    }
    setState(() => _playing = true);
    _ctrl.play();
  }

  void _checkEnd() {
    final value = _ctrl.value;
    if (value.isInitialized && value.position >= value.duration) {
      _ctrl.removeListener(_checkEnd);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StartScreen(progress: 4)),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_checkEnd);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _next,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _ctrl.value.aspectRatio == 0
                        ? 16 / 9
                        : _ctrl.value.aspectRatio,
                    child: VideoPlayer(_ctrl),
                  ),
                ),
                if (!_playing)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(220, 20, 20, 20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          _lines[_dialogIndex],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'ShareTechMono',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

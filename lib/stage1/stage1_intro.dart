import 'dart:async';
import 'package:flutter/material.dart';
import 'stage1_room.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class Stage1IntroScreen extends StatefulWidget {
  const Stage1IntroScreen({super.key});

  @override
  State<Stage1IntroScreen> createState() => _Stage1IntroScreenState();
}

class _Stage1IntroScreenState extends State<Stage1IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flickerCtrl;
  late Animation<double> _flicker;
  Timer? _stepTimer;
  Timer? _hintTimer;
  Timer? _fadeTimer;

  // dialogue

// --------------------------------------------------------
// text dialouge
// --------------------------------------------------------
 int step = 0;
  int dialogIndex = 0;
  bool showHint = false;
  bool fadeOut = false;

  final List<String> lines = [
    "....",
    " you: Where am I ?",
    "(crying sound)...?? ",
    "You: !! Who are you..?",
    "Entity: I just...",
    "Entity: Its your fault...",
  ];
// --------------------------------------------------------
// text effect
// --------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _flickerCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
          ..repeat(reverse: true);

    _flicker = Tween(begin: 0.6, end: 1.0).animate(_flickerCtrl);

    _stepTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => step = 1);
    });
  }

  void nextDialog() {
    if (dialogIndex < lines.length - 1) {
      setState(() {
        dialogIndex++;
        showHint = false;
      });

      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => showHint = true);
      });
    } else {
      setState(() => fadeOut = true);

      _fadeTimer?.cancel();
      _fadeTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        // Mark intro as seen so Stage1Room won't push it again.
        Stage1RoomScreen.introSeen = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Stage1RoomScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _hintTimer?.cancel();
    _fadeTimer?.cancel();
    _flickerCtrl.dispose();
    super.dispose();
  }
  // --------------------------------------------------------
// overide design
// --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (step == 0) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        body: Center(
          child: FadeTransition(
            opacity: _flicker,
            child: const Text(
              
// --------------------------------------------------------
//start text
// --------------------------------------------------------
              "A strange room surrounds you, and something feels wrong",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'ShareTechMono',
              ),
            ),
          ),
        ),
      );
    }

    // --------------------------------------------------------
// design and entity
// --------------------------------------------------------

    return Scaffold(
      body: GestureDetector(
        onTap: nextDialog,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: fadeOut ? 0 : 1,
          child: Stack(
             fit: StackFit.expand,
            children: [
              FadedAssetImage("assets/images/background.jpg", fit: BoxFit.cover),
              AnimatedAlign(
                duration: const Duration(milliseconds: 500),
                alignment: dialogIndex >= 2
                    ? Alignment.center
                    : const Alignment(1.2, 0),
                child: Opacity(
                  opacity: dialogIndex >= 2 ? 1 : 0,
                  child: FadedAssetImage(
                    "assets/images/entitys.png",
                    width: 600,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 50,
                child: TypingBox(
                  text: lines[dialogIndex],
                  showHint: showHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// --------------------------------------------------------
//text animation and design
// --------------------------------------------------------
class TypingBox extends StatefulWidget {
  final String text;
  final bool showHint;

  const TypingBox({super.key, required this.text, required this.showHint});

  @override
  State<TypingBox> createState() => _TypingBoxState();
}

class _TypingBoxState extends State<TypingBox> {
  String visible = "";

  @override
  void initState() {
    super.initState();
    type();
  }

  @override
  void didUpdateWidget(covariant TypingBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      visible = "";
      type();
    }
  }

  void type() async {
    for (int i = 0; i < widget.text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => visible = widget.text.substring(0, i + 1));
    }
  }

  // --------------------------------------------------------
//extra churba2x  a text for hint to tap screen
// --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 14, 14, 14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(visible),
          const SizedBox(width: 10),
          Opacity(
            opacity: widget.showHint ? 0.5 : 0,
            child: const Text(
              "tap to continue",
              style: TextStyle(fontSize: 10, fontFamily: 'ShareTechMono'),
            ),
          )
        ],
      ),
    );
  }
}

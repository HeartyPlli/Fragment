import 'package:flutter/material.dart';
import 'package:fragment/main.dart';
import 'package:fragment/background/video_background.dart';
import 'package:fragment/database/video_paths.dart';

class HowPlay extends StatelessWidget {
  const HowPlay({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              padding: const EdgeInsets.symmetric(
                horizontal: 55,
                vertical: 10,
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
                    'How to play?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: 'SpecialElite',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Tap on the arrows to navigate around the room.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'ShareTechMono',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 13),

                  Text(
                    'Some objects you can drag . ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'ShareTechMono',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 13),

                  Text(
                    'Interact with objects by tapping.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'ShareTechMono',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Select found items in your inventory and tap somewhere on screen to use them.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'ShareTechMono',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

// -----------------------------------------------------------------
// Back Button
// -----------------------------------------------------------------
                  IconButton(
                    iconSize: 50,
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

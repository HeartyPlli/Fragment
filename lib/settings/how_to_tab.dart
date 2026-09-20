import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'how_play.dart';

class HowToTabUI extends StatelessWidget {
  const HowToTabUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
// -----------------------------------------------------------------
// How to play button
// -----------------------------------------------------------------
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HowPlay(),
                transitionDuration: const Duration(milliseconds: 600),
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
          },
          child: const Text(
            'How to play?',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 25),

// -----------------------------------------------------------------
// Contact Me button
// -----------------------------------------------------------------
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
           
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            final url = Uri.parse("https://www.facebook.com/cagadas.heart/");
            if (!await launchUrl(url)) {
              throw 'Could not launch $url';
            }
          },
          child: const Text(
            'Contact Heart Cagadas for more info.',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

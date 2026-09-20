import 'package:flutter/material.dart';
import 'setting.dart';

class BottomNav extends StatelessWidget {
  final SettingsTab currentTab;
  final Function(SettingsTab) onChanged;

  const BottomNav({
    super.key,
    required this.currentTab,
    required this.onChanged,
  });

// -----------------------------------------------------------------
// switch page
// -----------------------------------------------------------------
  final double iconSize = 40;
  final double navWidth = 400;
  final double arrowHeight = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
// -----------------------------------------------------------------
// Arrow and Line
// -----------------------------------------------------------------
        SizedBox(
          width: navWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

// -----------------------------------------------------------------
// Animation of arrow and Line
// -----------------------------------------------------------------
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: _getAlignment(),
                child: Transform.translate(
                  offset: const Offset(0, 6),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: arrowHeight,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

       // const SizedBox(height: 0),
// -----------------------------------------------------------------
// Icon
// -----------------------------------------------------------------
Center(
          child: Container(
            width: navWidth,
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _icon(Icons.settings, SettingsTab.settings),
                SizedBox(width: 75,),
                _icon(Icons.help, SettingsTab.howTo),
                SizedBox(width: 75,),
                _icon(Icons.star, SettingsTab.achievements),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }
// -----------------------------------------------------------------
// Change tab
// -----------------------------------------------------------------
  Alignment _getAlignment() {
    switch (currentTab) {
      case SettingsTab.settings:
        return const Alignment(-0.9, 0);
      case SettingsTab.howTo:
        return const Alignment(0, 0);
      case SettingsTab.achievements:
        return const Alignment(0.9, 0);
    }
  }

// -----------------------------------------------------------------
//  tab
// -----------------------------------------------------------------
  Widget _icon(IconData icon, SettingsTab tab) {
    final isSelected = currentTab == tab;

    return GestureDetector(
      onTap: () => onChanged(tab),
      child: Icon(
        icon,
        size: iconSize,
        color: isSelected ? Colors.white : Colors.white70,
      ),
    );
  }
}

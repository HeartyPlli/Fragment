import 'package:flutter/material.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class PuzzleAssets {
  static const final11 = 'assets/images/Final/1.1.png';
  static const final12 = 'assets/images/Final/1.2.png';
  static const final13 = 'assets/images/Final/1.3.png';
  static const final14 = 'assets/images/Final/1.4.png';
  static const clue1 = 'assets/images/Final/clue1.png';
  static const clue2 = 'assets/images/Final/clue2.png';
  static const clue3 = 'assets/images/Final/clue3.png';
  static const clue5 = 'assets/images/Final/clue5.png';
  static const clue6 = 'assets/images/Final/clue6.png';
  static const fullClue = 'assets/images/Final/fullclue.png';
  static const heart = 'assets/images/Final/heart.png';
}

class PuzzleImage extends StatelessWidget {
  const PuzzleImage({
    super.key,
    required this.asset,
    required this.width,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FadedAssetImage(asset, width: width, fit: fit);
  }
}

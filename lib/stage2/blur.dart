import 'package:flutter/material.dart';
import 'package:fragment/widgets/faded_asset_image.dart';


class BlurOverlay extends StatelessWidget {
  final String assetPath;
  final double opacity;
  final double? width;
  final double? height;

  const BlurOverlay({
    super.key,
    required this.assetPath,
    this.opacity = 10.5,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: SizedBox(
              width: width,
              height: height,
              child: FadedAssetImage(
                assetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

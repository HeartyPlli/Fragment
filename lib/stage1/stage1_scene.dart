import 'package:flutter/material.dart';
import '../database/stage1/stage1_scene_data.dart';
import 'package:fragment/widgets/faded_asset_image.dart';
export '../database/stage1/stage1_scene_data.dart';

class StageScene extends StatefulWidget {
  const StageScene({
    super.key,
    required this.view,
    this.onTopExit,
    this.onHotspot,
    this.canToggle,
  });

  final StageView view;
  final VoidCallback? onTopExit;

  /// Called when a hotspot/button is tapped. Receives a logical id.
  final void Function(String id)? onHotspot;
  final bool Function(String id)? canToggle;

  @override
  State<StageScene> createState() => _StageSceneState();
}

class _StageSceneState extends State<StageScene> {
  final Map<String, bool> _toggled = {};
  final Map<String, bool> _pressed = {};

  @override
  Widget build(BuildContext context) {
    final hotspots = hotspotsForStageView(widget.view);
    return Stack(
      children: [
              Positioned.fill(
          child: FadedAssetImage(
            backgroundForStageView(widget.view),
            fit: BoxFit.cover,
          ),
        ),
        for (final h in hotspots) _button(h),
      ],
    );
  }

  Widget _button(StageHotspot h) {
    final toggled = _toggled[h.id] ?? false;
    final dx = toggled ? h.altLeft ?? h.left : h.left;
    final dy = toggled ? h.altTop ?? h.top + h.shift : h.top;
    final asset = toggled && h.altAsset != null ? h.altAsset! : h.asset;
    final bool isTopView = widget.view == StageView.sofaTop ||
        widget.view == StageView.kitchenTop ||
        widget.view == StageView.doorTop ||
        widget.view == StageView.computerTop;
    final bool isPressed = _pressed[h.id] ?? false;

    return AnimatedPositioned(
      duration: h.toggle && !h.instantToggle
          ? const Duration(seconds: 1)
          : const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      left: dx,
      top: dy,
      child: GestureDetector(
        onTapDown: (_) {
          if (isTopView) setState(() => _pressed[h.id] = true);
        },
        onTapCancel: () {
          if (isTopView) setState(() => _pressed[h.id] = false);
        },
        onTapUp: (_) {
          if (isTopView) setState(() => _pressed[h.id] = false);
        },
        onTap: () {
          if (h.toggle && (widget.canToggle?.call(h.id) ?? true)) {
            setState(() => _toggled[h.id] = !toggled);
          }
          widget.onHotspot?.call(h.id);
        },
        child: AnimatedScale(
          scale: isTopView && isPressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutBack,
          child: FadedAssetImage(asset, width: h.width),
        ),
      ),
    );
  }
}

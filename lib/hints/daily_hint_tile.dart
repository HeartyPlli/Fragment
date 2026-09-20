import 'package:flutter/material.dart';

import '../app_state.dart';
import '../audio/audio_controller.dart';

class DailyHintTile extends StatefulWidget {
  const DailyHintTile({
    super.key,
    required this.id,
    required this.number,
    required this.title,
    required this.body,
  });

  final String id;
  final int number;
  final String title;
  final String body;

  @override
  State<DailyHintTile> createState() => _DailyHintTileState();
}

class _DailyHintTileState extends State<DailyHintTile> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _unlocked = AppState.instance.isHintUnlockedToday(widget.id);
  }

  Future<void> _handleExpansion(bool expanded) async {
    if (!expanded || _unlocked || AppState.instance.remainingHintsToday <= 0) {
      return;
    }
    await playTap();
    final allowed = await AppState.instance.useHint(widget.id);
    if (!mounted) return;
    if (allowed) {
      setState(() => _unlocked = true);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You already used 2 hints today. Come back tomorrow.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppState.instance.hintUsageVersion,
      builder: (context, _, __) {
        final enabled = _unlocked || AppState.instance.remainingHintsToday > 0;
        final color = enabled ? Colors.white : Colors.white38;
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            enabled: enabled,
            collapsedIconColor: color,
            iconColor: Colors.white,
            onExpansionChanged: _handleExpansion,
            title: Text(
              '${widget.number}. ${widget.title}',
              style: TextStyle(
                color: color,
                fontFamily: 'ShareTechMono',
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _unlocked
                        ? widget.body
                        : 'Open this hint to use 1 of your 2 daily hints.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'ShareTechMono',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

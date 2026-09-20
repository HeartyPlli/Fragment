import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../app_state.dart';
import '../audio/audio_controller.dart';
import '../navigation/route_observer.dart';
import '../settings/setting.dart';
import '../start.dart';
import 'hint.dart';
import 'stage4_layout.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class _InventoryItem {
  final String id;
  final String asset;

  const _InventoryItem(this.id, this.asset);
}

enum _Stage4View { one, two, three, four, top }

enum _SubView {
  cloth1,
  cloth2,
  cloth3,
  copperHint,
  mushroom,
  fishrat,
  cup,
  matchbox,
  cCloseup,
  c20,
  bunnyDark,
  copperVideo,
}

class Stage4RoomScreen extends StatefulWidget {
  const Stage4RoomScreen({super.key});

  static bool complete = false;
  static Map<String, dynamic>? _savedProgress;
  static bool _discardNextSave = false;

  static void clearSavedProgress({bool discardNextSave = false}) {
    _savedProgress = null;
    complete = false;
    _discardNextSave = discardNextSave;
  }

  @override
  State<Stage4RoomScreen> createState() => _Stage4RoomScreenState();
}

class _Stage4RoomScreenState extends State<Stage4RoomScreen> with RouteAware {
  static const _copper = 'assets/images/Copper';
  static const _clue = 'assets/images/copperclue';

  final List<_InventoryItem?> _inventory =
      List<_InventoryItem?>.filled(12, null);
  final Set<String> _hintPieces = {};
  final Map<String, Offset> _hintPieceOffsets = {};
  final Map<String, bool> _collected = {};
  final Map<String, bool> _matchToggles = {};
  final Set<String> _matchUnlocked = {};

  _Stage4View _view = _Stage4View.one;
  _SubView? _subView;
  String? _selectedItemId;
  String? _closeupAsset;
  bool _shake = false;
  bool _cupSolved = false;
  bool _mushroomSolved = false;
  bool _fishratSolved = false;
  bool _lidOnBowl = false;
  bool _lidLifted = false;
  bool _bunny2Down = false;
  bool _c5ChangedMatchbox = false;
  int _inventoryPage = 0;
  Timer? _bunnyTimer;
  VideoPlayerController? _videoCtrl;
  Future<void>? _videoFuture;
  bool _routeSubscribed = false;

  final List<List<int?>> _fishratGrid =
      List.generate(6, (_) => List<int?>.filled(6, null));

  static const List<List<int>> _fishratAnswer = [
    [2, 2, 1, 2, 1, 2],
    [2, 2, 1, 1, 2, 1],
    [2, 1, 2, 1, 2, 1],
    [1, 2, 1, 2, 1, 2],
    [1, 1, 2, 1, 2, 2],
    [1, 2, 1, 2, 2, 1],
  ];

  @override
  void initState() {
    super.initState();
    AudioController.instance.playMusic(AppState.stage4Music);
    AppState.instance.setCurrentStage(4);
    _restoreProgress();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (Stage4RoomScreen._discardNextSave) {
      Stage4RoomScreen._discardNextSave = false;
    } else {
      _saveProgress();
    }
    _bunnyTimer?.cancel();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeSubscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      routeObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void didPushNext() {
    _saveProgress();
  }

  @override
  void didPopNext() {
    AudioController.instance.playMusic(AppState.stage4Music);
  }

  void _restoreProgress() {
    final saved = Stage4RoomScreen._savedProgress;
    if (saved == null) return;
    _inventory.setAll(
      0,
      List<_InventoryItem?>.from(saved['inventory'] as List),
    );
    _hintPieces
      ..clear()
      ..addAll(Set<String>.from(saved['hintPieces'] as Set));
    _hintPieceOffsets
      ..clear()
      ..addAll(Map<String, Offset>.from(saved['hintPieceOffsets'] as Map));
    _collected
      ..clear()
      ..addAll(Map<String, bool>.from(saved['collected'] as Map));
    _matchToggles
      ..clear()
      ..addAll(Map<String, bool>.from(saved['matchToggles'] as Map));
    _matchUnlocked
      ..clear()
      ..addAll(Set<String>.from(saved['matchUnlocked'] as Set));
    _view = saved['view'] as _Stage4View? ?? _view;
    _subView = saved['subView'] as _SubView?;
    if (_subView == _SubView.copperVideo) _subView = null;
    _selectedItemId = saved['selectedItemId'] as String?;
    _closeupAsset = saved['closeupAsset'] as String?;
    _shake = saved['shake'] as bool? ?? false;
    _cupSolved = saved['cupSolved'] as bool? ?? false;
    _mushroomSolved = saved['mushroomSolved'] as bool? ?? false;
    _fishratSolved = saved['fishratSolved'] as bool? ?? false;
    _lidOnBowl = saved['lidOnBowl'] as bool? ?? false;
    _lidLifted = saved['lidLifted'] as bool? ?? false;
    _bunny2Down = saved['bunny2Down'] as bool? ?? false;
    _c5ChangedMatchbox = saved['c5ChangedMatchbox'] as bool? ?? false;
    _inventoryPage = saved['inventoryPage'] as int? ?? 0;
    final grid = saved['fishratGrid'] as List;
    for (var row = 0; row < _fishratGrid.length; row++) {
      _fishratGrid[row] = List<int?>.from(grid[row] as List);
    }
  }

  void _saveProgress() {
    Stage4RoomScreen._savedProgress = {
      'inventory': List<_InventoryItem?>.from(_inventory),
      'hintPieces': Set<String>.from(_hintPieces),
      'hintPieceOffsets': Map<String, Offset>.from(_hintPieceOffsets),
      'collected': Map<String, bool>.from(_collected),
      'matchToggles': Map<String, bool>.from(_matchToggles),
      'matchUnlocked': Set<String>.from(_matchUnlocked),
      'view': _view,
      'subView': _subView,
      'selectedItemId': _selectedItemId,
      'closeupAsset': _closeupAsset,
      'shake': _shake,
      'cupSolved': _cupSolved,
      'mushroomSolved': _mushroomSolved,
      'fishratSolved': _fishratSolved,
      'lidOnBowl': _lidOnBowl,
      'lidLifted': _lidLifted,
      'bunny2Down': _bunny2Down,
      'c5ChangedMatchbox': _c5ChangedMatchbox,
      'inventoryPage': _inventoryPage,
      'fishratGrid': [
        for (final row in _fishratGrid) List<int?>.from(row),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            _inventoryColumn(),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: Stage4Layout.sceneWidth,
                  height: Stage4Layout.sceneHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _background()),
                      if (_subView == null) ..._mainOverlays(),
                      if (_subView != null) _subScene(),
                      if (_shake)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                                color: Colors.black.withOpacity(0.08)),
                          ),
                        ),
                      if (_subView == null) ..._navArrows(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: withTap(() => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        )),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: AppState.instance.hintOn,
                    builder: (context, hintOn, _) {
                      if (!hintOn) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.white),
                        onPressed: withTap(() => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HintScreen(),
                              ),
                            )),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _background() {
    final asset = _backgroundAsset();
    return FadedAssetImage(asset,
        width: Stage4Layout.sceneWidth,
        height: Stage4Layout.sceneHeight,
        fit: BoxFit.cover);
  }

  String _backgroundAsset() {
    if (Stage4RoomScreen.complete && _view == _Stage4View.one) {
      return '$_clue/endingbackground.png';
    }
    switch (_view) {
      case _Stage4View.one:
        return '$_copper/1background.png';
      case _Stage4View.two:
        return '$_copper/2background.png';
      case _Stage4View.three:
        return '$_copper/3background.png';
      case _Stage4View.four:
        return '$_copper/4background.png';
      case _Stage4View.top:
        return '$_copper/topbackground.png';
    }
  }

  List<Widget> _mainOverlays() {
    if (Stage4RoomScreen.complete && _view == _Stage4View.one) {
      return [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _returnToStart,
          ),
        ),
      ];
    }

    switch (_view) {
      case _Stage4View.one:
        return [
          _hotspot(Stage4Layout.clothOffset, Stage4Layout.clothWidth,
              '$_copper/cloth.png', () {
            _subView = _SubView.cloth1;
            setState(() {});
          }),
          _hotspot(Stage4Layout.copperHintOffset, Stage4Layout.copperHintWidth,
              '$_copper/copperhint.png', _tapCopperHint),
          ..._smallHintPieces(),
        ];
      case _Stage4View.two:
        return [
          _hotspot(
              Stage4Layout.mushroomOffset,
              Stage4Layout.mushroomWidth,
              '$_copper/mushroom.png',
              () => setState(() => _subView = _SubView.mushroom)),
          _hotspot(
              Stage4Layout.fishratOffset,
              Stage4Layout.fishratWidth,
              '$_copper/fishrat.png',
              () => setState(() => _subView = _SubView.fishrat)),
        ];
      case _Stage4View.three:
        return [
          _hotspot(Stage4Layout.bowlOffset, Stage4Layout.bowlWidth,
              '$_copper/bowl.png', _tapBowl),
          if (_lidOnBowl)
            _hotspot(
              Stage4Layout.bowlOffset + const Offset(24, -22),
              74,
              '$_clue/lid.png',
              _tapBowl,
            ),
          if (_lidLifted && !_isCollected('c4'))
            _hotspot(
              Stage4Layout.bowlOffset + const Offset(42, 12),
              Stage4Layout.smallClueWidth,
              '$_clue/c4.png',
              () => _collect('c4', '$_clue/c4.png'),
            ),
          _hotspot(Stage4Layout.bunnyOffset, Stage4Layout.bunnyWidth,
              '$_copper/bunny.png', () {}),
          _hotspot(Stage4Layout.bunnyOffset + const Offset(6, 2),
              Stage4Layout.bunnyWidth, '$_copper/bunny1.png', _enterBunnyDark),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            left: Stage4Layout.bunnyOffset.dx + 12,
            top: Stage4Layout.bunnyOffset.dy + (_bunny2Down ? 70 : 4),
            child: GestureDetector(
              onTap: _tapBunny2,
              child: FadedAssetImage('$_copper/bunny2.png',
                  width: Stage4Layout.bunnyWidth),
            ),
          ),
          if (!_isCollected('c11'))
            _hotspot(Stage4Layout.c11Offset, Stage4Layout.smallClueWidth,
                '$_clue/c11.png', () => _collect('c11', '$_clue/c11.png')),
        ];
      case _Stage4View.four:
        return [
          _hotspot(
            Stage4Layout.matchboxOffset,
            Stage4Layout.matchboxWidth,
            _c5ChangedMatchbox ? '$_clue/c22.png' : '$_copper/matchbox.png',
            _tapMatchboxMain,
          ),
          _hotspot(
              Stage4Layout.cupOffset,
              Stage4Layout.cupWidth,
              '$_copper/cup.png',
              () => setState(() => _subView = _SubView.cup)),
          if (!_isCollected('c8'))
            _hotspot(Stage4Layout.c8Offset, Stage4Layout.smallClueWidth,
                '$_clue/c8.png', () => _collect('c8', '$_clue/c8.png')),
        ];
      case _Stage4View.top:
        return [];
    }
  }

  Widget _hotspot(
      Offset offset, double width, String asset, VoidCallback onTap) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTap: withTap(onTap),
        child: FadedAssetImage(asset, width: width),
      ),
    );
  }

  List<Widget> _smallHintPieces() {
    return [
      for (final id in _hintPieces)
        if (Stage4Layout.defaultHintOffsets[id] != null)
          Positioned(
            left: Stage4Layout.copperHintOffset.dx +
                Stage4Layout.defaultHintOffsets[id]!.dx * 0.16,
            top: Stage4Layout.copperHintOffset.dy +
                Stage4Layout.defaultHintOffsets[id]!.dy * 0.16,
            child: FadedAssetImage('$_clue/$id.png', width: 18),
          ),
    ];
  }

  List<Widget> _navArrows() {
    return [
      Positioned(
        left: 4,
        top: 240,
        child: _arrow(Icons.arrow_left, () {
          setState(() => _view = _leftOf(_view));
        }),
      ),
      Positioned(
        right: 4,
        top: 240,
        child: _arrow(Icons.arrow_right, () {
          setState(() => _view = _rightOf(_view));
        }),
      ),
      Positioned(
        top: 8,
        left: 0,
        right: 0,
        child: Center(
          child: _arrow(Icons.arrow_drop_up, () {
            setState(() => _view = _Stage4View.top);
          }),
        ),
      ),
      if (_view == _Stage4View.top)
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: _arrow(Icons.arrow_drop_down, () {
              setState(() => _view = _Stage4View.one);
            }),
          ),
        ),
    ];
  }

  Widget _arrow(IconData icon, VoidCallback onTap) {
    return Listener(
      onPointerDown: (_) => AudioController.instance.suppressNextTap(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }

  _Stage4View _leftOf(_Stage4View view) {
    switch (view) {
      case _Stage4View.one:
        return _Stage4View.two;
      case _Stage4View.two:
        return _Stage4View.four;
      case _Stage4View.three:
        return _Stage4View.one;
      case _Stage4View.four:
        return _Stage4View.three;
      case _Stage4View.top:
        return _Stage4View.one;
    }
  }

  _Stage4View _rightOf(_Stage4View view) {
    switch (view) {
      case _Stage4View.one:
        return _Stage4View.three;
      case _Stage4View.two:
        return _Stage4View.one;
      case _Stage4View.three:
        return _Stage4View.four;
      case _Stage4View.four:
        return _Stage4View.two;
      case _Stage4View.top:
        return _Stage4View.one;
    }
  }

  Widget _subScene() {
    switch (_subView!) {
      case _SubView.cloth1:
        return _clothView(
            '$_copper/cloth1.png', () => _subView = _SubView.cloth2, [
          if (!_isCollected('c6'))
            _hotspot(const Offset(260, 255), Stage4Layout.smallClueWidth,
                '$_clue/c6.png', () => _collect('c6', '$_clue/c6.png')),
        ]);
      case _SubView.cloth2:
        return _clothView(
            '$_copper/cloth2.png', () => _subView = _SubView.cloth3, [
          if (!_isCollected('c2'))
            _hotspot(const Offset(260, 255), Stage4Layout.smallClueWidth,
                '$_clue/c2.png', () => _collect('c2', '$_clue/c2.png')),
        ]);
      case _SubView.cloth3:
        return _clothView('$_copper/cloth3.png', () => _subView = null, []);
      case _SubView.copperHint:
        return _copperHintView();
      case _SubView.mushroom:
        return _mushroomView();
      case _SubView.fishrat:
        return _fishratView();
      case _SubView.cup:
        return _cupView();
      case _SubView.matchbox:
        return _matchboxView();
      case _SubView.cCloseup:
        return _imageCloseup(_closeupAsset ?? '$_clue/c1.png');
      case _SubView.c20:
        return _plainCloseup('$_copper/c20background.png', '$_clue/c20.png');
      case _SubView.bunnyDark:
        return _bunnyDarkView();
      case _SubView.copperVideo:
        return _copperVideoView();
    }
  }

  Widget _clothView(
      String background, VoidCallback advance, List<Widget> overlays) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(advance),
      child: Stack(
        children: [
          Positioned.fill(
              child: FadedAssetImage(background, fit: BoxFit.cover)),
          ...overlays,
        ],
      ),
    );
  }

  Widget _withBack(String background, List<Widget> children) {
    return Stack(
      children: [
        Positioned.fill(child: FadedAssetImage(background, fit: BoxFit.cover)),
        ...children,
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: _arrow(
                Icons.arrow_drop_down, () => setState(() => _subView = null)),
          ),
        ),
      ],
    );
  }

  Widget _copperHintView() {
    return _withBack('$_copper/copperhint.png', [
      _hotspot(Stage4Layout.paperOffset, Stage4Layout.paperWidth,
          '$_copper/paper1.png', () {}),
      _hotspot(Stage4Layout.c21Offset, Stage4Layout.c21Width, '$_clue/21.png',
          () {}),
      for (final id in _hintPieces) _hintPiece(id),
    ]);
  }

  Widget _hintPiece(String id) {
    final offset = _hintPieceOffsets[id] ??
        Stage4Layout.defaultHintOffsets[id] ??
        const Offset(220, 220);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final next = offset + details.delta;
            _hintPieceOffsets[id] = Offset(
              next.dx.clamp(0, Stage4Layout.sceneWidth - 60).toDouble(),
              next.dy.clamp(0, Stage4Layout.sceneHeight - 60).toDouble(),
            );
          });
        },
        child: FadedAssetImage('$_clue/$id.png', width: 58),
      ),
    );
  }

  Widget _mushroomView() {
    return _withBack('$_copper/mushroomcloseup.png', [
      Center(
        child: GestureDetector(
          onTap: _mushroomSolved
              ? null
              : () => _showNumberPuzzle(
                    length: 3,
                    choices: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
                    answer: const [3, 1, 5],
                    onSolved: () => setState(() => _mushroomSolved = true),
                  ),
          child: FadedAssetImage('$_copper/mushroom.png', width: 150),
        ),
      ),
      if (_mushroomSolved && !_isCollected('keyc'))
        _glowReward(Stage4Layout.keyOffset, '$_copper/keyc.png', 'keyc'),
    ]);
  }

  Widget _fishratView() {
    return _withBack('$_copper/fishratbackground.png', [
      Positioned(
        left: Stage4Layout.fishratGridOffset.dx,
        top: Stage4Layout.fishratGridOffset.dy,
        child: SizedBox(
          width: Stage4Layout.fishratGridSize,
          height: Stage4Layout.fishratGridSize,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
            ),
            itemCount: 36,
            itemBuilder: (context, index) {
              final r = index ~/ 6;
              final c = index % 6;
              final value = _fishratGrid[r][c];
              final given = _isFishratGiven(r, c);
              return GestureDetector(
                onTap: given
                    ? null
                    : () {
                        setState(() {
                          _fishratGrid[r][c] = value == null
                              ? 2
                              : value == 2
                                  ? 1
                                  : null;
                          _checkFishratSolved();
                        });
                      },
                child: Center(
                  child: value == null
                      ? Container(
                          width: Stage4Layout.fishratDotSize,
                          height: Stage4Layout.fishratDotSize,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Opacity(
                          opacity: given ? 0.45 : 1,
                          child: Transform.rotate(
                            angle: (r + c).isEven ? math.pi / 2 : math.pi,
                            child: FadedAssetImage(
                              value == 2
                                  ? '$_copper/rat.png'
                                  : '$_copper/fish.png',
                              width: Stage4Layout.fishratIconWidth,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
      if (_fishratSolved && !_isCollected('c13'))
        _glowReward(Stage4Layout.c13RewardOffset, '$_clue/c13.png', 'c13'),
    ]);
  }

  bool _isFishratGiven(int r, int c) {
    const givens = {
      '2,0': 2,
      '4,0': 1,
      '0,2': 1,
      '1,2': 1,
      '4,2': 2,
      '1,3': 1,
      '5,4': 2,
      '1,5': 1,
    };
    final value = givens['$r,$c'];
    if (value != null && _fishratGrid[r][c] == null) _fishratGrid[r][c] = value;
    return value != null;
  }

  void _checkFishratSolved() {
    for (var r = 0; r < 6; r++) {
      for (var c = 0; c < 6; c++) {
        if (_fishratGrid[r][c] != _fishratAnswer[r][c]) return;
      }
    }
    _fishratSolved = true;
    _pulseDark();
  }

  Widget _cupView() {
    return _withBack('$_copper/cupbackground.png', [
      _hotspot(Stage4Layout.cup1Offset, Stage4Layout.cupCloseupWidth,
          '$_copper/cup1.png', () {}),
      _hotspot(Stage4Layout.cup2Offset, Stage4Layout.cupCloseupWidth,
          '$_copper/cup2.png', () {}),
      if (!_cupSolved)
        Center(
          child: ElevatedButton(
            onPressed: () => _showNumberPuzzle(
              length: 2,
              choices: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
              answer: const [5, 9],
              onSolved: () => setState(() => _cupSolved = true),
            ),
            child: const Text('Puzzle'),
          ),
        ),
      if (_cupSolved && !_isCollected('lid'))
        _glowReward(Stage4Layout.lidOffset, '$_clue/lid.png', 'lid'),
    ]);
  }

  Widget _matchboxView() {
    return _withBack('$_copper/match/matchboxbackground.png', [
      for (var i = 1; i <= 9; i++) _matchTile(i),
      ..._matchRewards(),
    ]);
  }

  Widget _matchTile(int number) {
    final id = 'm$number';
    final offset =
        Offset(85 + ((number - 1) % 3) * 125, 90 + ((number - 1) ~/ 3) * 115);
    return _hotspot(
        offset, 85, '$_copper/match/$id.png', () => _tapMatchTile(id));
  }

  List<Widget> _matchRewards() {
    final rewards = <Widget>[];
    if (_matchToggles['m2'] ?? false) {
      rewards.addAll([
        if (!_isCollected('c10'))
          _hotspot(const Offset(120, 220), 46, '$_clue/c10.png',
              () => _collect('c10', '$_clue/c10.png')),
        if (!_isCollected('c7'))
          _hotspot(const Offset(180, 220), 46, '$_clue/c7.png',
              () => _collect('c7', '$_clue/c7.png')),
      ]);
    }
    if (_matchToggles['m4'] ?? false) {
      rewards.addAll([
        if (!_isCollected('c9'))
          _hotspot(const Offset(120, 335), 46, '$_clue/c9.png',
              () => _collect('c9', '$_clue/c9.png')),
        if (!_isCollected('c12'))
          _hotspot(const Offset(180, 335), 46, '$_clue/c12.png',
              () => _collect('c12', '$_clue/c12.png')),
        if (!_isCollected('c20'))
          _hotspot(const Offset(240, 335), 46, '$_clue/c20.png',
              () => _collect('c20', '$_clue/c20.png')),
      ]);
    }
    if (_matchToggles['m6'] ?? false) {
      rewards.addAll([
        if (!_isCollected('c13m6'))
          _hotspot(const Offset(300, 335), 46, '$_clue/c13.png',
              () => _collect('c13m6', '$_clue/c13.png')),
        if (!_isCollected('c15'))
          _hotspot(const Offset(360, 335), 46, '$_clue/c15.png',
              () => _collect('c15', '$_clue/c15.png')),
      ]);
    }
    if (_matchToggles['m8'] ?? false) {
      rewards.addAll([
        if (!_isCollected('c3'))
          _hotspot(const Offset(240, 440), 46, '$_clue/c3.png',
              () => _collect('c3', '$_clue/c3.png')),
        if (!_isCollected('c5'))
          _hotspot(const Offset(300, 440), 46, '$_clue/c5.png',
              () => _collect('c5', '$_clue/c5.png')),
      ]);
    }
    return rewards;
  }

  Widget _plainCloseup(String background, String image) {
    return _withBack(background, [
      Center(
          child: FadedAssetImage(image,
              width: Stage4Layout.plainCloseupImageWidth)),
    ]);
  }

  Widget _imageCloseup(String image) {
    Offset offset =
        _hintPieceOffsets['closeup-$image'] ?? Stage4Layout.closeupStartOffset;
    return _withBack('$_copper/closesupbackground.png', [
      Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              offset += details.delta;
              _hintPieceOffsets['closeup-$image'] = offset;
            });
          },
          child: FadedAssetImage(image, width: Stage4Layout.closeupImageWidth),
        ),
      ),
    ]);
  }

  Widget _bunnyDarkView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_selectedItemId == 'c22') {
          setState(() {
            _removeInventoryItem('c22');
            _selectedItemId = null;
            _subView = _SubView.copperVideo;
            _startCopperVideo();
          });
        } else {
          setState(() => _subView = null);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 40, end: 240),
              duration: const Duration(seconds: 7),
              builder: (context, size, _) => Icon(
                Icons.visibility,
                color: Colors.red.shade900,
                size: size,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _copperVideoView() {
    final future = _videoFuture;
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            _videoCtrl == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Container(
          color: Colors.white,
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoCtrl!.value.aspectRatio,
              child: VideoPlayer(_videoCtrl!),
            ),
          ),
        );
      },
    );
  }

  Widget _glowReward(Offset offset, String asset, String id) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTap: () => _collect(id, asset),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black, blurRadius: 18, spreadRadius: 6),
            ],
          ),
          child: FadedAssetImage(asset, width: Stage4Layout.rewardWidth),
        ),
      ),
    );
  }

  void _tapCopperHint() {
    final id = _selectedItemId;
    if (id != null && _canPlaceOnHint(id)) {
      setState(() {
        _hintPieces.add(id == 'c13m6' ? 'c13' : id);
        _removeInventoryItem(id);
        _selectedItemId = null;
      });
      return;
    }
    setState(() => _subView = _SubView.copperHint);
  }

  bool _canPlaceOnHint(String id) {
    return {
      'c6',
      'c7',
      'c8',
      'c9',
      'c10',
      'c11',
      'c12',
      'c13',
      'c13m6',
      'c15',
    }.contains(id);
  }

  void _tapMatchboxMain() {
    if (_selectedItemId == 'c5') {
      setState(() {
        _c5ChangedMatchbox = true;
        _removeInventoryItem('c5');
        _selectedItemId = null;
      });
      _addInventoryItem(
          const _InventoryItem('c22', 'assets/images/copperclue/c22.png'));
      return;
    }
    setState(() => _subView = _SubView.matchbox);
  }

  void _tapMatchTile(String id) {
    if (id == 'm2' && !_matchUnlocked.contains(id)) {
      _showShapePuzzle(
        answer: const ['triangle', 'square', 'circle', 'star'],
        onSolved: () => setState(() => _matchUnlocked.add(id)),
      );
      return;
    }
    if (id == 'm4' && !_matchUnlocked.contains(id)) {
      _showNumberPuzzle(
        length: 4,
        choices: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
        answer: const [2, 1, 3, 6],
        onSolved: () => setState(() => _matchUnlocked.add(id)),
      );
      return;
    }
    if (id == 'm6' && !_matchUnlocked.contains(id)) {
      _showNumberPuzzle(
        length: 5,
        choices: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
        answer: const [2, 0, 9, 6, 5],
        onSolved: () => setState(() => _matchUnlocked.add(id)),
      );
      return;
    }
    if (id == 'm8' && !_matchUnlocked.contains(id)) {
      if (_selectedItemId == 'keyc') {
        setState(() {
          _matchUnlocked.add(id);
          _removeInventoryItem('keyc');
          _selectedItemId = null;
        });
      } else {
        _showInfoMessage('Locked');
      }
      return;
    }
    if ({'m2', 'm4', 'm6', 'm8'}.contains(id)) {
      setState(() => _matchToggles[id] = !(_matchToggles[id] ?? false));
    }
  }

  void _tapBowl() {
    if (_selectedItemId == 'lid' && !_lidOnBowl) {
      setState(() {
        _lidOnBowl = true;
        _removeInventoryItem('lid');
        _selectedItemId = null;
      });
      return;
    }
    if (_lidOnBowl && !_lidLifted) {
      setState(() => _lidLifted = true);
      _pulseDark();
    }
  }

  void _tapBunny2() {
    if (_selectedItemId == 'knife' && !_bunny2Down) {
      setState(() {
        _bunny2Down = true;
        _selectedItemId = null;
      });
    }
  }

  void _enterBunnyDark() {
    setState(() => _subView = _SubView.bunnyDark);
    _bunnyTimer?.cancel();
    _bunnyTimer = Timer(const Duration(seconds: 7), () {
      if (mounted && _subView == _SubView.bunnyDark) {
        setState(() => _subView = null);
      }
    });
  }

  void _startCopperVideo() {
    _bunnyTimer?.cancel();
    _videoCtrl?.dispose();
    _videoCtrl = VideoPlayerController.asset('assets/videos/copper.mp4');
    _videoFuture = _videoCtrl!.initialize().then((_) {
      _videoCtrl!.addListener(_checkCopperVideoEnd);
      _videoCtrl!.play();
      setState(() {});
    });
  }

  void _checkCopperVideoEnd() {
    final ctrl = _videoCtrl;
    if (ctrl == null) return;
    if (ctrl.value.isInitialized &&
        ctrl.value.position >= ctrl.value.duration) {
      ctrl.removeListener(_checkCopperVideoEnd);
      Stage4RoomScreen.complete = true;
      AppState.instance.unlockStage(5);
      _returnToStart(progress: 5);
    }
  }

  void _collect(String id, String asset) {
    if (_isCollected(id)) return;
    _addInventoryItem(_InventoryItem(id, asset));
    setState(() => _collected[id] = true);
  }

  bool _isCollected(String id) => _collected[id] ?? false;

  void _addInventoryItem(_InventoryItem item) {
    if (_inventory.any((slot) => slot?.id == item.id)) return;
    final index = _inventory.indexWhere((slot) => slot == null);
    if (index == -1) return;
    setState(() => _inventory[index] = item);
  }

  void _removeInventoryItem(String id) {
    final index = _inventory.indexWhere((slot) => slot?.id == id);
    if (index != -1) _inventory[index] = null;
  }

  void _pulseDark() {
    setState(() => _shake = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _shake = false);
    });
  }

  void _showInfoMessage(String message) {
    if (RegExp(r'\b(lock|locked)\b', caseSensitive: false).hasMatch(message)) {
      AudioController.instance.lock();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(220, 20, 20, 20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'ShareTechMono',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNumberPuzzle({
    required int length,
    required List<int> choices,
    required List<int> answer,
    required VoidCallback onSolved,
  }) {
    final values = List<int>.filled(length, 0);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setPuzzleState) {
          final solved =
              List.generate(length, (i) => choices[values[i]] == answer[i])
                  .every((ok) => ok);
          return Dialog(
            backgroundColor: const Color(0xFFE9E9E9),
            child: SizedBox(
              width: length * 90 + 90,
              height: 230,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < length; i++)
                        _numberColumn(
                          value: choices[values[i]],
                          onUp: () => setPuzzleState(
                            () => values[i] = (values[i] + 1) % choices.length,
                          ),
                          onDown: () => setPuzzleState(
                            () => values[i] = (values[i] - 1 + choices.length) %
                                choices.length,
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: solved
                        ? () {
                            onSolved();
                            Navigator.of(context).pop();
                            _pulseDark();
                          }
                        : null,
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _numberColumn({
    required int value,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      children: [
        IconButton(onPressed: onUp, icon: const Icon(Icons.keyboard_arrow_up)),
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Text('$value', style: const TextStyle(fontSize: 28)),
        ),
        IconButton(
            onPressed: onDown, icon: const Icon(Icons.keyboard_arrow_down)),
      ],
    );
  }

  void _showShapePuzzle({
    required List<String> answer,
    required VoidCallback onSolved,
  }) {
    final shapes = ['circle', 'square', 'heart', 'star', 'triangle', 'down'];
    final icons = {
      'circle': Icons.circle_outlined,
      'square': Icons.crop_square,
      'heart': Icons.favorite_border,
      'star': Icons.star_border,
      'triangle': Icons.change_history,
      'down': Icons.change_history,
    };
    final values = List<int>.filled(answer.length, 0);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setPuzzleState) {
          final solved = List.generate(
            answer.length,
            (i) => shapes[values[i]] == answer[i],
          ).every((ok) => ok);
          return Dialog(
            backgroundColor: const Color(0xFFE9E9E9),
            child: SizedBox(
              width: 500,
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < answer.length; i++)
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: [
                                  Colors.green,
                                  Colors.pink,
                                  Colors.yellow,
                                  Colors.blue,
                                ][i % 4],
                                shape: BoxShape.circle,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setPuzzleState(
                                () =>
                                    values[i] = (values[i] + 1) % shapes.length,
                              ),
                              icon: const Icon(Icons.keyboard_arrow_up),
                            ),
                            Transform.rotate(
                              angle: shapes[values[i]] == 'down' ? math.pi : 0,
                              child: Icon(icons[shapes[values[i]]], size: 48),
                            ),
                            IconButton(
                              onPressed: () => setPuzzleState(
                                () => values[i] =
                                    (values[i] - 1 + shapes.length) %
                                        shapes.length,
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ],
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: solved
                        ? () {
                            onSolved();
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inventoryColumn() {
    final visible = _inventory.skip(_inventoryPage * 6).take(6).toList();
    return SizedBox(
      width: Stage4Layout.inventoryWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 25, top: 8, bottom: 8),
        child: Column(
          children: [
            for (final slot in visible)
              GestureDetector(
                onTap: slot == null ? null : () => _tapInventory(slot),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: Stage4Layout.inventorySlotSize,
                  height: Stage4Layout.inventorySlotSize,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(220, 229, 168, 140),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white70),
                  ),
                  child: slot == null
                      ? null
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: FadedAssetImage(slot.asset,
                                  fit: BoxFit.contain),
                            ),
                            if (_selectedItemId == slot.id)
                              Container(color: Colors.black.withOpacity(0.48)),
                          ],
                        ),
                ),
              ),
            IconButton(
              onPressed: () =>
                  setState(() => _inventoryPage = _inventoryPage == 0 ? 1 : 0),
              icon: Icon(
                _inventoryPage == 0
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tapInventory(_InventoryItem item) {
    if ((item.id == 'c1' && _selectedItemId == 'c2') ||
        (item.id == 'c2' && _selectedItemId == 'c1')) {
      setState(() {
        _removeInventoryItem('c1');
        _removeInventoryItem('c2');
        _selectedItemId = null;
      });
      _addInventoryItem(
          const _InventoryItem('c1c2', 'assets/images/copperclue/c1.png'));
      return;
    }
    if ((item.id == 'c3' && _selectedItemId == 'c4') ||
        (item.id == 'c4' && _selectedItemId == 'c3')) {
      setState(() {
        _removeInventoryItem('c3');
        _removeInventoryItem('c4');
        _selectedItemId = null;
      });
      _addInventoryItem(
          const _InventoryItem('knife', 'assets/images/copperclue/knife.png'));
      return;
    }
    if (item.id == 'c1' || item.id == 'c2' || item.id == 'c1c2') {
      _closeupAsset = item.asset;
      setState(() => _subView = _SubView.cCloseup);
      return;
    }
    if (item.id == 'c20') {
      setState(() => _subView = _SubView.c20);
      return;
    }
    setState(
        () => _selectedItemId = _selectedItemId == item.id ? null : item.id);
  }

  void _returnToStart({int progress = 5}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => StartScreen(progress: progress)),
      (route) => false,
    );
  }
}

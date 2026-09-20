import 'package:flutter/material.dart';
import '../app_state.dart';
import '../audio/audio_controller.dart';
import '../navigation/route_observer.dart';
import '../settings/setting.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'stage1_scene.dart';
import 'stage1_intro.dart';
import 'stage1_layout.dart';
import '../database/stage1/stage1_subscenes.dart';
import '../start.dart';
import 'blur.dart';
import 'hint.dart';
import '../puzzle.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class _InventoryItem {
  final String id;
  final String asset;

  const _InventoryItem(this.id, this.asset);
}

class Stage1RoomScreen extends StatefulWidget {
  const Stage1RoomScreen({super.key});

  // Track whether the intro has already played.
  static bool introSeen = false;
  static bool postIntroDialogShown = false;
  static Map<String, dynamic>? _savedProgress;
  static bool _discardNextSave = false;

  static void clearSavedProgress({bool discardNextSave = false}) {
    _savedProgress = null;
    introSeen = false;
    postIntroDialogShown = false;
    _discardNextSave = discardNextSave;
  }

  @override
  State<Stage1RoomScreen> createState() => _Stage1RoomScreenState();
}

class _Stage1RoomScreenState extends State<Stage1RoomScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  StageView _view = StageView.sofa;
  int _inventoryPage = 0;
  final List<_InventoryItem?> _inventory =
      List<_InventoryItem?>.filled(10, null);
  bool _secondInventoryBatchVisible = false;
  static const _blurAsset = 'assets/images/blur.png';
  static const double _sceneWidth = Stage1Layout.sceneWidth;
  static const double _sceneHeight = Stage1Layout.sceneHeight;
  bool _lightsOn = true;
  String? _selectedItemId;
  bool _final11Collected = false;
  bool _final12Revealed = false;
  bool _final12Collected = false;
  bool _final13Collected = false;
  bool _final14Collected = false;
  bool _frame1FinalPlaced = false;
  bool _frame1Final12Placed = false;
  bool _frame1Final13Placed = false;
  bool _frame1Final14Placed = false;
  bool _frame1Glow = false;
  bool _frame1RewardCollected = false;
  bool _heartPlacedOnDoor = false;
  bool _clue1Collected = false;
  bool _clue2Collected = false;
  bool _clue3Collected = false;
  bool _clue6Collected = false;
  bool _table4Solved = false;
  bool _table6Solved = false;
  bool _clue6PlacedOnTable = false;
  bool _clue5CloseupVisible = false;
  final Set<String> _hintPlacedClues = {};
  final Map<String, Offset> _dragOffsets = {};
  bool _routeSubscribed = false;

// -------------------------------------------------------------------------
//Vid
// -------------------------------------------------------------------------
  late final AnimationController _blinkCtrl;

  SubScene? _activeSub;
  final Map<String, bool> _subToggles = {};
  final Map<String, bool> _subPressed = {};
  bool _ft1Mounted = false;
  bool _ft1Visible = false;
  int _doorCloseupTapCount = 0;

  static const Offset _hintBarrierOffset = Stage1Layout.hintBarrierOffset;
  static const double _hintBarrierSize = Stage1Layout.hintBarrierSize;

  // Faucet water overlay placement. Edit left/top to move ft1.png.
  static const double _ft1CloseupLeft = Stage1Layout.ft1CloseupLeft;
  static const double _ft1CloseupTop = Stage1Layout.ft1CloseupTop;
  static const double _ft1CloseupWidth = Stage1Layout.ft1CloseupWidth;
  static const double _ft1CloseupHeight = Stage1Layout.ft1CloseupHeight;
  static const double _hintPlacedClueWidth = Stage1Layout.hintPlacedClueWidth;
  static const double _tablePlacedClue6Width =
      Stage1Layout.tablePlacedClue6Width;
  static const double _heartDoorLeft = Stage1Layout.heartDoorLeft;
  static const double _heartDoorTop = Stage1Layout.heartDoorTop;
  static const double _heartDoorWidth = Stage1Layout.heartDoorWidth;

  @override
  void initState() {
    super.initState();
    AudioController.instance.playMusic(AppState.stageMusic);
    AppState.instance.setCurrentStage(1);
    Stage1RoomScreen.introSeen = AppState.instance.stageIntroSeen(1);
    Stage1RoomScreen.postIntroDialogShown =
        AppState.instance.stagePostIntroDialogShown(1);
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.15,
      upperBound: 0.28,
    )..repeat(reverse: true);
    _restoreProgress();
    _syncWaterLoopWithFt1();

    if (!Stage1RoomScreen.introSeen) {
      Future.delayed(Duration.zero, () {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const Stage1IntroScreen()),
        );
      });
      Stage1RoomScreen.introSeen = true;
      AppState.instance.setStageIntroSeen(1, true);
    } else if (!Stage1RoomScreen.postIntroDialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Scaffold(
              backgroundColor: Colors.black54,
              body: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(200, 20, 20, 20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      "ugghh my head.... Ohh I'm in my room",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'ShareTechMono',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        Stage1RoomScreen.postIntroDialogShown = true;
        AppState.instance.setStagePostIntroDialogShown(1, true);
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (Stage1RoomScreen._discardNextSave) {
      Stage1RoomScreen._discardNextSave = false;
    } else {
      _saveProgress();
    }
    AudioController.instance.setWaterLoop(false);
    _blinkCtrl.dispose();
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
    AudioController.instance.setWaterLoop(false);
  }

  @override
  void didPopNext() {
    AudioController.instance.playMusic(AppState.stageMusic);
    _syncWaterLoopWithFt1();
  }

  void _restoreProgress() {
    final saved = Stage1RoomScreen._savedProgress;
    if (saved == null) return;
    _view = saved['view'] as StageView? ?? _view;
    _inventoryPage = saved['inventoryPage'] as int? ?? _inventoryPage;
    _inventory.setAll(
      0,
      List<_InventoryItem?>.from(saved['inventory'] as List),
    );
    _secondInventoryBatchVisible =
        saved['secondInventoryBatchVisible'] as bool? ?? false;
    _lightsOn = saved['lightsOn'] as bool? ?? true;
    _selectedItemId = saved['selectedItemId'] as String?;
    _final11Collected = saved['final11Collected'] as bool? ?? false;
    _final12Revealed = saved['final12Revealed'] as bool? ?? false;
    _final12Collected = saved['final12Collected'] as bool? ?? false;
    _final13Collected = saved['final13Collected'] as bool? ?? false;
    _final14Collected = saved['final14Collected'] as bool? ?? false;
    _frame1FinalPlaced = saved['frame1FinalPlaced'] as bool? ?? false;
    _frame1Final12Placed = saved['frame1Final12Placed'] as bool? ?? false;
    _frame1Final13Placed = saved['frame1Final13Placed'] as bool? ?? false;
    _frame1Final14Placed = saved['frame1Final14Placed'] as bool? ?? false;
    _frame1Glow = saved['frame1Glow'] as bool? ?? false;
    _frame1RewardCollected = saved['frame1RewardCollected'] as bool? ?? false;
    _heartPlacedOnDoor = saved['heartPlacedOnDoor'] as bool? ?? false;
    _clue1Collected = saved['clue1Collected'] as bool? ?? false;
    _clue2Collected = saved['clue2Collected'] as bool? ?? false;
    _clue3Collected = saved['clue3Collected'] as bool? ?? false;
    _clue6Collected = saved['clue6Collected'] as bool? ?? false;
    _table4Solved = saved['table4Solved'] as bool? ?? false;
    _table6Solved = saved['table6Solved'] as bool? ?? false;
    _clue6PlacedOnTable = saved['clue6PlacedOnTable'] as bool? ?? false;
    _clue5CloseupVisible = saved['clue5CloseupVisible'] as bool? ?? false;
    _hintPlacedClues
      ..clear()
      ..addAll(Set<String>.from(saved['hintPlacedClues'] as Set));
    _dragOffsets
      ..clear()
      ..addAll(Map<String, Offset>.from(saved['dragOffsets'] as Map));
    _subToggles
      ..clear()
      ..addAll(Map<String, bool>.from(saved['subToggles'] as Map));
    _subPressed
      ..clear()
      ..addAll(Map<String, bool>.from(saved['subPressed'] as Map));
    _activeSub = subScenes[saved['activeSubId'] as String?];
    _ft1Mounted = saved['ft1Mounted'] as bool? ?? false;
    _ft1Visible = saved['ft1Visible'] as bool? ?? false;
    _doorCloseupTapCount = saved['doorCloseupTapCount'] as int? ?? 0;
  }

  void _saveProgress() {
    Stage1RoomScreen._savedProgress = {
      'view': _view,
      'inventoryPage': _inventoryPage,
      'inventory': List<_InventoryItem?>.from(_inventory),
      'secondInventoryBatchVisible': _secondInventoryBatchVisible,
      'lightsOn': _lightsOn,
      'selectedItemId': _selectedItemId,
      'final11Collected': _final11Collected,
      'final12Revealed': _final12Revealed,
      'final12Collected': _final12Collected,
      'final13Collected': _final13Collected,
      'final14Collected': _final14Collected,
      'frame1FinalPlaced': _frame1FinalPlaced,
      'frame1Final12Placed': _frame1Final12Placed,
      'frame1Final13Placed': _frame1Final13Placed,
      'frame1Final14Placed': _frame1Final14Placed,
      'frame1Glow': _frame1Glow,
      'frame1RewardCollected': _frame1RewardCollected,
      'heartPlacedOnDoor': _heartPlacedOnDoor,
      'clue1Collected': _clue1Collected,
      'clue2Collected': _clue2Collected,
      'clue3Collected': _clue3Collected,
      'clue6Collected': _clue6Collected,
      'table4Solved': _table4Solved,
      'table6Solved': _table6Solved,
      'clue6PlacedOnTable': _clue6PlacedOnTable,
      'clue5CloseupVisible': _clue5CloseupVisible,
      'hintPlacedClues': Set<String>.from(_hintPlacedClues),
      'dragOffsets': Map<String, Offset>.from(_dragOffsets),
      'subToggles': Map<String, bool>.from(_subToggles),
      'subPressed': Map<String, bool>.from(_subPressed),
      'activeSubId': _activeSub?.id,
      'ft1Mounted': _ft1Mounted,
      'ft1Visible': _ft1Visible,
      'doorCloseupTapCount': _doorCloseupTapCount,
    };
  }

  void _go(StageView v) => setState(() => _view = v);

// -------------------------------------------------------------------------
// design start
// -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final bool isTopView = _isTop(_view);
    final bool bottomArrowVisible = _activeSub != null || isTopView;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            _inventoryColumn(),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: _sceneWidth,
                  height: _sceneHeight,
                  child: Stack(
                    children: [
                      // Dark flicker base
                      Positioned.fill(
                        child: FadeTransition(
                          opacity: _blinkCtrl,
                          child: Container(color: Colors.black),
                        ),
                      ),

// -------------------------------------------------------------------------
// Arrow
// -------------------------------------------------------------------------
                      _sceneFrame(),
                      _floatingDots(),
                      if (_activeSub != null) _buildSubScene(_activeSub!),
                      if (_clue5CloseupVisible) _clue5CloseupOverlay(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _lightsOn ? 0.0 : 0.65,
                        child: IgnorePointer(
                          ignoring: true, // keep taps available even when dark
                          child: Container(color: Colors.black),
                        ),
                      ),
                      // Navigation arrows
                      if (!bottomArrowVisible)
                        Positioned(
                          left: 6,
                          top: 0,
                          bottom: 0,
                          child: _arrow(Icons.arrow_left, _left(_view)),
                        ),
                      if (!bottomArrowVisible)
                        Positioned(
                          right: 6,
                          top: 0,
                          bottom: 0,
                          child: _arrow(Icons.arrow_right, _right(_view)),
                        ),
                      if (!bottomArrowVisible)
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _arrow(Icons.arrow_drop_up, _topOf(_view)),
                          ),
                        ),
                      if (bottomArrowVisible)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (_activeSub != null) {
                                    setState(() {
                                      _clue5CloseupVisible = false;
                                      _activeSub = null;
                                      _subToggles.clear();
                                      _subPressed.clear();
                                      _doorCloseupTapCount = 0;
                                    });
                                  } else {
                                    _go(_baseOf(_view) ?? StageView.sofa);
                                  }
                                },
                                child: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const BlurOverlay(
                        assetPath: _blurAsset,
                        opacity: 1.0,
                        width: 540,
                        height: 550,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------------
// Setting and Eye icon
// -----------------------------------------------------------------

            SizedBox(
              width: 60,
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    top: 5,
                    child: IconButton(
                      icon: const Icon(Icons.settings,
                          color: Colors.white, size: 25),
                      onPressed: withTap(() {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const SettingsScreen(),
                            transitionDuration:
                                const Duration(milliseconds: 300),
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
                      }),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: AppState.instance.hintOn,
                    builder: (context, hintOn, _) {
                      if (!hintOn) return const SizedBox.shrink();
                      return Positioned(
                        right: 20,
                        top: 50,
                        child: IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: withTap(() {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const HintScreen(),
                                transitionDuration:
                                    const Duration(milliseconds: 300),
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
                          }),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Settings button
          ],
        ),
      ),
    );
  }

// -----------------------------------------------------------------
// Arrow Action
// -----------------------------------------------------------------

  Widget _sceneFrame() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Stack(
        key: ValueKey(_view),
        children: [
          StageScene(
            view: _view,
            onTopExit: () {},
            onHotspot: _handleHotspot,
            canToggle: _canToggleStageHotspot,
          ),
          if (_view == StageView.door && _heartPlacedOnDoor)
            Positioned(
              left: 220,
              top: 120,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const StartScreen(progress: 2),
                  ),
                ),
                child: FadedAssetImage(
                  'assets/images/door2.png',
                  width: 115,
                ),
              ),
            ),
          if (_view == StageView.sofa && _frame1FinalPlaced)
            Positioned(
              left: 258,
              top: 117,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  boxShadow: _frame1Glow
                      ? const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ]
                      : null,
                ),
                child: const PuzzleImage(
                  asset: PuzzleAssets.final11,
                  width: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleHotspot(String id) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (id == 'door-switch') {
      setState(() => _lightsOn = !_lightsOn);
      return;
    }
    // suppress toast/snack for kitchen doors
    if (id == 'k-door1' || id == 'k-door2') {
      return;
    }
    if (id == 'sofa-frame1' && _placeSelectedFramePiece()) {
      return;
    }
    final sub = subScenes[id];
    if (sub != null) {
      setState(() {
        _activeSub = sub;
        _subToggles.clear();
      });
      return;
    }
  }

  bool _canToggleStageHotspot(String id) {
    if (id == 'k-door1' || id == 'k-door2') {
      _showLockedMessage();
      return false;
    }
    if (id == 'c-door1') {
      if (!_allFramePiecesPlaced) {
        _showLockedMessage();
        return false;
      }
    }
    return true;
  }

  bool get _allFramePiecesPlaced =>
      _frame1FinalPlaced &&
      _frame1Final12Placed &&
      _frame1Final13Placed &&
      _frame1Final14Placed;

  bool _placeSelectedFramePiece() {
    switch (_selectedItemId) {
      case 'final-1-1':
        if (!_frame1FinalPlaced) {
          _placeFramePiece('final-1-1');
          return true;
        }
        break;
      case 'final-1-2':
        if (!_frame1Final12Placed) {
          _placeFramePiece('final-1-2');
          return true;
        }
        break;
      case 'final-1-3':
        if (!_frame1Final13Placed) {
          _placeFramePiece('final-1-3');
          return true;
        }
        break;
      case 'final-1-4':
        if (!_frame1Final14Placed) {
          _placeFramePiece('final-1-4');
          return true;
        }
        break;
    }
    return false;
  }

  void _placeFramePiece(String id) {
    setState(() {
      if (id == 'final-1-1') _frame1FinalPlaced = true;
      if (id == 'final-1-2') _frame1Final12Placed = true;
      if (id == 'final-1-3') _frame1Final13Placed = true;
      if (id == 'final-1-4') _frame1Final14Placed = true;
      _selectedItemId = null;
      _removeInventoryItem(id);
      _frame1Glow = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _frame1Glow = false);
    });
  }

  Widget _buildSubScene(SubScene scene) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (scene.id == 'c-hint') {
                  _placeSelectedClueOnHint();
                }
              },
              child: FadedAssetImage(
                scene.background,
                width: _sceneWidth,
                height: _sceneHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
          for (final ov in scene.overlays) _subButton(scene.id, ov),
          if (scene.id == 'sofa-table' && _clue6PlacedOnTable)
            _draggablePlacedImage(
              keyId: 'table-clue6',
              asset: PuzzleAssets.clue6,
              initialOffset: const Offset(340, 110),
              width: _tablePlacedClue6Width,
            ),
          if (scene.id == 'sofa-chair' &&
              (_subToggles['sofa-chair-pillow'] ?? false) &&
              !_final11Collected)
//----------------------------------------------------------------------------------------------------------------------------

            Positioned(
              left: 120,
              top: 202,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem('final-1-1', PuzzleAssets.final11),
                  );
                  setState(() => _final11Collected = true);
                },
                child: const PuzzleImage(
                  asset: PuzzleAssets.final11,
                  width: 36,
                ),
              ),
            ),
//----------------------------------------------------------------------------------------------------------------------------

          if (scene.id == 'sofa-table' &&
              (_subToggles['sofa-table-t2'] ?? false) &&
              !_hasInventoryItem('clue1'))
            Positioned(
              left: 285,
              top: 190,
              child: GestureDetector(
                onTap: () {
                  _addClue('clue1', PuzzleAssets.clue1);
                  setState(() => _clue1Collected = true);
                },
                child: const PuzzleImage(
                  asset: PuzzleAssets.clue1,
                  width: 42,
                ),
              ),
            ),
          if (scene.id == 'sofa-frame1' &&
              !_clue1Collected &&
              !_hasInventoryItem('clue1'))
            Positioned(
              left: 340,
              top: 50,
              child: GestureDetector(
                onTap: () {
                  _addClue('clue1', PuzzleAssets.clue1);
                  setState(() => _clue1Collected = true);
                },
                child: const PuzzleImage(
                  asset: PuzzleAssets.clue1,
                  width: 36,
                ),
              ),
            ),
//----------------------------------------------------------------------------------------------------------------------------

          if (scene.id == 'sofa-table' &&
              (_subToggles['sofa-table-t4'] ?? false) &&
              _table4Solved &&
              !_final14Collected)
            Positioned(
              left: 260,
              top: 225,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem('final-1-4', PuzzleAssets.final14),
                  );
                  setState(() => _final14Collected = true);
                },
                child: const PuzzleImage(
                  asset: PuzzleAssets.final14,
                  width: 44,
                ),
              ),
            ),

          if (scene.id == 'sofa-table' &&
              (_subToggles['sofa-table-t6'] ?? false) &&
              _table6Solved) ...[
            if (!_final13Collected)
              Positioned(
                left: 200,
                top: 185,
                child: GestureDetector(
                  onTap: () {
                    _addInventoryItem(
                      const _InventoryItem('final-1-3', PuzzleAssets.final13),
                    );
                    setState(() => _final13Collected = true);
                  },
                  child: const PuzzleImage(
                    asset: PuzzleAssets.final13,
                    width: 44,
                  ),
                ),
              ),
            if (!_clue3Collected)
              Positioned(
                left: 290,
                top: 186,
                child: GestureDetector(
                  onTap: () {
                    _addClue('clue3', PuzzleAssets.clue3);
                    setState(() => _clue3Collected = true);
                  },
                  child: const PuzzleImage(
                    asset: PuzzleAssets.clue3,
                    width: 42,
                  ),
                ),
              ),
          ],
          if (scene.id == 'c-mirror' && _final12Revealed && !_final12Collected)
            Positioned(
              left: 245,
              top: 116,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem('final-1-2', PuzzleAssets.final12),
                  );
                  setState(() => _final12Collected = true);
                },
                child: const PuzzleImage(
                  asset: PuzzleAssets.final12,
                  width: 70,
                ),
              ),
            ),
          if (scene.id == 'k-4') ...[
            if (!_clue2Collected)
              Positioned(
                left: 415,
                top: 254,
                child: GestureDetector(
                  onTap: () {
                    _addClue('clue2', PuzzleAssets.clue2);
                    setState(() => _clue2Collected = true);
                  },
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 1.4, sigmaY: 1.4),
                    child: const PuzzleImage(
                      asset: PuzzleAssets.clue2,
                      width: 44,
                    ),
                  ),
                ),
              ),
            if (!_clue6Collected)
              Positioned(
                left: 42,
                top: 310,
                child: GestureDetector(
                  onTap: () {
                    _addClue('clue6', PuzzleAssets.clue6);
                    setState(() => _clue6Collected = true);
                  },
                  child: const PuzzleImage(
                    asset: PuzzleAssets.clue6,
                    width: 45,
                  ),
                ),
              ),
          ],

          if (scene.id == 'door-main')
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleDoorCloseupTap,
              ),
            ),
          if (scene.id == 'door-main' && _heartPlacedOnDoor)
            Positioned(
              left: _heartDoorLeft,
              top: _heartDoorTop,
              child: _shakingHeart(_heartDoorWidth),
            ),
          if (scene.id == 'k-3' && _ft1Mounted)
            _ft1Overlay(
              left: _ft1CloseupLeft,
              top: _ft1CloseupTop,
              width: _ft1CloseupWidth,
              height: _ft1CloseupHeight,
            ),
          if (scene.id == 'c-hint') ..._hintClueWidgets(),
          if (scene.id == 'sofa-frame1') ..._frame1RewardWidgets(),
          if (scene.id == 'sofa-table') _clue5Widget(),
        ],
      ),
    );
  }

  Widget _clue5Widget() {
    return Positioned(
      left: 168,
      top: 48,
      child: GestureDetector(
        onTap: _showClue5Closeup,
        onDoubleTap: _placeSelectedClue6OnTable,
        child: const PuzzleImage(
          asset: PuzzleAssets.clue5,
          width: 78,
        ),
      ),
    );
  }

//-------------------------------------------------------------------------------------------------------------------------
  List<Widget> _frame1RewardWidgets() {
    final widgets = <Widget>[
      if (_frame1FinalPlaced)
        _placedFramePieceWidget(
          left: 209,
          top: 115,
          width: 73,
          asset: PuzzleAssets.final11,
        ),
      if (_frame1Final12Placed)
        _placedFramePieceWidget(
          left: 282,
          top: 115,
          width: 73,
          asset: PuzzleAssets.final12,
        ),
      if (_frame1Final13Placed)
        _placedFramePieceWidget(
          left: 209,
          top: 204,
          width: 73,
          asset: PuzzleAssets.final13,
        ),
      if (_frame1Final14Placed)
        _placedFramePieceWidget(
          left: 283,
          top: 203,
          width: 73,
          asset: PuzzleAssets.final14,
        ),
    ];

    if (_allFramePiecesPlaced && !_frame1RewardCollected) {
      widgets.addAll([
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.black.withOpacity(0.28)),
          ),
        ),
        Positioned(
          left: 258,
          top: 174,
          child: GestureDetector(
            onTap: () {
              _addInventoryItem(
                const _InventoryItem('heart', PuzzleAssets.heart),
              );
              setState(() => _frame1RewardCollected = true);
            },
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 22,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: _shakingHeart(58),
            ),
          ),
        ),
      ]);
    }

    return widgets;
  }

  Widget _shakingHeart(double width) {
    return AnimatedBuilder(
      animation: _blinkCtrl,
      builder: (context, child) {
        final dx = math.sin(_blinkCtrl.value * 80) * 4;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: PuzzleImage(asset: PuzzleAssets.heart, width: width),
    );
  }

  Widget _placedFramePieceWidget({
    required double left,
    required double top,
    required double width,
    required String asset,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          boxShadow: _frame1Glow
              ? const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 18,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: FadedAssetImage(asset, width: width),
      ),
    );
  }

  List<Widget> _hintClueWidgets() {
    return [
      for (final id in _hintPlacedClues)
        _draggablePlacedImage(
          keyId: 'hint-$id',
          asset: _assetForInventoryId(id),
          initialOffset: _defaultHintClueOffset(id),
          width: _hintPlacedClueWidth,
        ),
    ];
  }

  Widget _draggablePlacedImage({
    required String keyId,
    required String asset,
    required Offset initialOffset,
    required double width,
  }) {
    final offset = _dragOffsets[keyId] ?? initialOffset;
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final next = offset + details.delta;
            _dragOffsets[keyId] = Offset(
              next.dx.clamp(0, _sceneWidth - width).toDouble(),
              next.dy.clamp(0, _sceneHeight - width).toDouble(),
            );
          });
        },
        child: FadedAssetImage(asset, width: width),
      ),
    );
  }

//-----------------------------------------------------------------------------------------------------
  Offset _defaultHintClueOffset(String id) {
    switch (id) {
      case 'clue1':
        return const Offset(120, 220);
      case 'clue2':
        return const Offset(210, 220);
      case 'clue3':
        return const Offset(300, 220);
      default:
        return const Offset(160, 240);
    }
  }

  String _assetForInventoryId(String id) {
    switch (id) {
      case 'clue1':
        return PuzzleAssets.clue1;
      case 'clue2':
        return PuzzleAssets.clue2;
      case 'clue3':
        return PuzzleAssets.clue3;
      case 'clue6':
        return PuzzleAssets.clue6;
      case 'heart':
        return PuzzleAssets.heart;
      case 'final-1-1':
        return PuzzleAssets.final11;
      case 'final-1-2':
        return PuzzleAssets.final12;
      case 'final-1-3':
        return PuzzleAssets.final13;
      case 'final-1-4':
        return PuzzleAssets.final14;
      default:
        return '';
    }
  }

  void _placeSelectedClueOnHint() {
    if (_selectedItemId != 'clue1' &&
        _selectedItemId != 'clue2' &&
        _selectedItemId != 'clue3') {
      return;
    }
    setState(() {
      _hintPlacedClues.add(_selectedItemId!);
      _removeInventoryItem(_selectedItemId!);
      _selectedItemId = null;
    });
  }

  void _placeSelectedClue6OnTable() {
    if (_selectedItemId != 'clue6' || _clue6PlacedOnTable) return;
    setState(() {
      _clue6PlacedOnTable = true;
      _removeInventoryItem('clue6');
      _selectedItemId = null;
    });
  }

  Widget _subButton(String sceneId, SubHotspot ov) {
    if (sceneId == 'sofa-frame1' &&
        ((_frame1FinalPlaced && ov.id == 'frame1-01-1') ||
            (_frame1Final12Placed && ov.id == 'frame1-01-2') ||
            (_frame1Final13Placed && ov.id == 'frame1-01-3') ||
            (_frame1Final14Placed && ov.id == 'frame1-01-4'))) {
      return const SizedBox.shrink();
    }

    final key = '$sceneId-${ov.id}';
    final toggled = _subToggles[key] ?? false;
    final baseOffset = _dragOffsets[key] ?? ov.offset;
    final dx = toggled ? ov.altLeft ?? baseOffset.dx : baseOffset.dx;
    final dy = toggled
        ? ov.altTop ?? baseOffset.dy + (ov.toggleShift ? ov.shiftAmount : 0)
        : baseOffset.dy;
    final asset = toggled && ov.toggleAsset && ov.altAsset != null
        ? ov.altAsset!
        : ov.asset;
    final canPressAnimate =
        ov.id == 'lamp' || (sceneId == 'k-3' && ov.id == 'ft2');
    final canRotate = sceneId == 'k-3' && (ov.id == 'ft4' || ov.id == 'ft5');
    final isPressed = _subPressed[key] ?? false;

    if (sceneId == 'c-hint' && ov.draggable) {
      return Positioned(
        left: baseOffset.dx,
        top: baseOffset.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final next = baseOffset + details.delta;
              final maxX = math.max(
                _hintBarrierOffset.dx,
                _hintBarrierOffset.dx + _hintBarrierSize - ov.width,
              );
              final maxY = math.max(
                _hintBarrierOffset.dy,
                _hintBarrierOffset.dy + _hintBarrierSize - ov.width,
              );
              _dragOffsets[key] = Offset(
                next.dx.clamp(_hintBarrierOffset.dx, maxX).toDouble(),
                next.dy.clamp(_hintBarrierOffset.dy, maxY).toDouble(),
              );
            });
          },
          child: FadedAssetImage(asset, width: ov.width),
        ),
      );
    }

    return AnimatedPositioned(
      duration: !ov.instantToggle &&
              (ov.toggleShift || ov.altLeft != null || ov.altTop != null)
          ? const Duration(seconds: 1)
          : const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      left: dx,
      top: dy,
      child: GestureDetector(
        onDoubleTap: () {
          if (sceneId == 'c-mirror' &&
              (ov.id == 'mepic' || ov.id == 'mirror')) {
            setState(() => _final12Revealed = true);
          }
        },
        onTapDown: (_) {
          if (canPressAnimate) setState(() => _subPressed[key] = true);
        },
        onTapCancel: () {
          if (canPressAnimate) setState(() => _subPressed[key] = false);
        },
        onTapUp: (_) {
          if (canPressAnimate) setState(() => _subPressed[key] = false);
        },
        onTap: () {
          AudioController.instance.tap();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          if (ov.id == 'mepic') {
            _showInfoMessage("Its me.");
            return;
          }
          if (ov.id == 'laptop') {
            final screen = subScenes['laptop-screen'];
            if (screen != null) {
              setState(() {
                _activeSub = screen;
                _subToggles.clear();
                _subPressed.clear();
              });
            }
            return;
          }
          if (sceneId == 'k-3' && ov.id == 'ft2') {
            _showFt1();
            return;
          }
          if (canRotate) {
            setState(() => _subToggles[key] = !toggled);
            return;
          }
          if (ov.id == 't2') {
            _showLockedMessage();
            return;
          }
          if (ov.id == 't4') {
            if (_table4Solved) {
              setState(() => _subToggles[key] = !toggled);
            } else {
              _showShapePuzzle();
            }
            return;
          }
          if (ov.id == 't6') {
            if (_table6Solved) {
              setState(() => _subToggles[key] = !toggled);
            } else {
              _showNumberPuzzle();
            }
            return;
          }
          if (ov.id == 'clue2') {
            _addClue('clue2', PuzzleAssets.clue2);
            return;
          }
          if (sceneId == 'sofa-frame1' && _placeSelectedFramePiece()) {
            return;
          }
          if (ov.toggleAsset || ov.toggleShift) {
            setState(() => _subToggles[key] = !toggled);
          }
        },
        child: AnimatedScale(
          scale: canPressAnimate && isPressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutBack,
          child: AnimatedRotation(
            turns: canRotate && toggled ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: FadedAssetImage(asset, width: ov.width),
          ),
        ),
      ),
    );
  }

  void _handleDoorCloseupTap() {
    if (_selectedItemId == 'heart' && !_heartPlacedOnDoor) {
      setState(() {
        _heartPlacedOnDoor = true;
        _removeInventoryItem('heart');
        _selectedItemId = null;
      });
      return;
    }
    if (_heartPlacedOnDoor) {
      AppState.instance.unlockStage(2);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StartScreen(progress: 2)),
      );
      return;
    }
    _doorCloseupTapCount += 1;
    if (_doorCloseupTapCount >= 1) {
      _doorCloseupTapCount = 0;
      _showLockedMessage();
    }
  }

  void _showFt1() {
    setState(() {
      _ft1Mounted = true;
      _ft1Visible = true;
    });
    _syncWaterLoopWithFt1();
  }

  void _hideFt1() {
    setState(() => _ft1Visible = false);
    _syncWaterLoopWithFt1();
  }

  void _syncWaterLoopWithFt1() {
    AudioController.instance.setWaterLoop(_ft1Visible);
  }

  Widget _ft1Overlay({
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: _hideFt1,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _ft1Visible ? 1 : 0),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          onEnd: () {
            if (!_ft1Visible && mounted) {
              setState(() => _ft1Mounted = false);
            }
          },
          builder: (context, reveal, child) {
            return Opacity(
              opacity: reveal,
              child: ClipRect(
                child: Align(
                  alignment: _ft1Visible
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  heightFactor: reveal.clamp(0.001, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: AnimatedBuilder(
            animation: _blinkCtrl,
            builder: (context, _) {
              final t = ((_blinkCtrl.value - 0.15) / 0.13).clamp(0.0, 1.0);
              final pulseWidth = width + math.sin(t * math.pi) * 2;
              return FadedAssetImage(
                'assets/images/faucet/ft1.png',
                width: pulseWidth,
                height: height,
                fit: BoxFit.fill,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _floatingDots() {
    const dots = [
      Offset(70, 95),
      Offset(170, 430),
      Offset(320, 120),
      Offset(455, 360),
      Offset(500, 210),
      Offset(245, 300),
    ];

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _blinkCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              for (var i = 0; i < dots.length; i++)
                Positioned(
                  left: dots[i].dx + math.sin(_blinkCtrl.value * 18 + i) * 3,
                  top: dots[i].dy + math.cos(_blinkCtrl.value * 16 + i) * 3,
                  child: Container(
                    width: i.isEven ? 7 : 6,
                    height: i.isEven ? 7 : 6,
                    decoration: BoxDecoration(
                      color: i.isEven
                          ? Colors.white.withOpacity(0.70)
                          : Colors.black.withOpacity(0.72),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.35),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _addClue(String id, String asset) {
    if (_hasInventoryItem('fullclue') || _hasInventoryItem(id)) return;

    _addInventoryItem(_InventoryItem(id, asset));
  }

 /* void _mergeCluesFromInventory(String pressedId) {
    if (pressedId != 'clue1' && pressedId != 'clue2') return;

    final otherId = pressedId == 'clue1' ? 'clue2' : 'clue1';
    if (!_hasInventoryItem(otherId)) return;

    setState(() {
      _removeInventoryItem('clue1');
      _removeInventoryItem('clue2');
      _selectedItemId = null;
    });
    _addInventoryItem(
      const _InventoryItem('fullclue', PuzzleAssets.fullClue),
    );
  }
*/
  void _addInventoryItem(_InventoryItem item) {
    if (_hasInventoryItem(item.id)) return;

    final index = _inventory.indexWhere((slot) => slot == null);
    if (index == -1) return;

    setState(() {
      _inventory[index] = item;
      if (index >= 5) {
        _secondInventoryBatchVisible = true;
      }
    });
  }

  bool _hasInventoryItem(String id) {
    return _inventory.any((item) => item?.id == id);
  }

  void _removeInventoryItem(String id) {
    final index = _inventory.indexWhere((item) => item?.id == id);
    if (index != -1) {
      _inventory[index] = null;
      _collapseEmptySecondInventoryBatch();
    }
  }

  void _collapseEmptySecondInventoryBatch() {
    final secondBatchEmpty = _inventory.skip(5).every((item) => item == null);
    if (!secondBatchEmpty) return;

    _secondInventoryBatchVisible = false;
    _inventoryPage = 0;
  }

  void _showLockedMessage() {
    _showInfoMessage("It's lock...");
  }

  void _showInfoMessage(String message) {
    if (RegExp(r'\b(lock|locked)\b', caseSensitive: false).hasMatch(message)) {
      AudioController.instance.lock();
    }

    BuildContext? dialogContext;

    Future.delayed(const Duration(seconds: 8), () {
      final contextToClose = dialogContext;
      if (!mounted || contextToClose == null || !contextToClose.mounted) return;
      Navigator.of(contextToClose).maybePop();
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        dialogContext = context;
        return GestureDetector(
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
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'ShareTechMono',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) => dialogContext = null);
  }

  void _showInventoryImage(_InventoryItem item) {
    showDialog(
      context: context,
      barrierColor: const Color(0xAAE0E0E0),
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFFE5E5E5),
        body: Stack(
          children: [
            Center(
              child: FadedAssetImage(
                item.asset,
                width: 320,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  iconSize: 54,
                  color: Colors.black87,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClue5Closeup() {
    setState(() => _clue5CloseupVisible = true);
  }

  Widget _clue5CloseupOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF123527),
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: _placeSelectedClue6OnTable,
                child: const PuzzleImage(
                  asset: PuzzleAssets.clue5,
                  width: 208,
                ),
              ),
            ),
            if (_clue6PlacedOnTable)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: PuzzleImage(
                    asset: PuzzleAssets.clue6,
                    width: 208,
                  ),
                ),
              ),
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  iconSize: 54,
                  color: Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () => setState(() => _clue5CloseupVisible = false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//////////////---------------------------------------------------------------------------------------------------------------------
  void _showShapePuzzle() {
    final shapes = ['circle', 'square', 'triangle', 'down', 'star', 'heart'];
    final labels = {
      'circle': Icons.circle_outlined,
      'square': Icons.crop_square,
      'triangle': Icons.change_history,
      'down': Icons.change_history,
      'star': Icons.star_border,
      'heart': Icons.favorite_border,
    };
    final values = [0, 0, 0];

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => StatefulBuilder(
        builder: (context, setPuzzleState) {
          final solved = shapes[values[0]] == 'down' &&
              shapes[values[1]] == 'circle' &&
              shapes[values[2]] == 'square';

          return Dialog(
            backgroundColor: const Color(0xFFE9E9E9),
            child: SizedBox(
              width: 420,
              height: 270,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < 3; i++)
                        _shapeColumn(
                          icon: labels[shapes[values[i]]]!,
                          upsideDown: shapes[values[i]] == 'down',
                          onUp: () => setPuzzleState(() {
                            values[i] = (values[i] + 1) % shapes.length;
                          }),
                          onDown: () => setPuzzleState(() {
                            values[i] =
                                (values[i] - 1 + shapes.length) % shapes.length;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (!solved) return;
                      setState(() {
                        _table4Solved = true;
                        _subToggles['sofa-table-t4'] = true;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      solved ? 'OK' : 'OK',
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'ShareTechMono',
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNumberPuzzle() {
    final values = [0, 0, 0, 0];

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => StatefulBuilder(
        builder: (context, setPuzzleState) {
          final solved = values[0] == 8 &&
              values[1] == 3 &&
              values[2] == 7 &&
              values[3] == 2;

          return Dialog(
            backgroundColor: const Color(0xFFE9E9E9),
            child: SizedBox(
              width: 460,
              height: 270,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < 4; i++)
                        _numberColumn(
                          value: values[i],
                          onUp: () => setPuzzleState(() {
                            values[i] = (values[i] + 1) % 10;
                          }),
                          onDown: () => setPuzzleState(() {
                            values[i] = (values[i] - 1 + 10) % 10;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (!solved) return;
                      setState(() {
                        _table6Solved = true;
                        _subToggles['sofa-table-t6'] = true;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'ShareTechMono',
                        fontSize: 22,
                      ),
                    ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onUp,
          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
        ),
        Container(
          width: 70,
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 42,
              fontFamily: 'ShareTechMono',
            ),
          ),
        ),
        IconButton(
          onPressed: onDown,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        ),
      ],
    );
  }

  Widget _shapeColumn({
    required IconData icon,
    required bool upsideDown,
    required VoidCallback onUp,
    required VoidCallback onDown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onUp,
          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
          ),
          child: Transform.rotate(
            angle: upsideDown ? math.pi : 0,
            child: Icon(icon, color: Colors.black, size: 54),
          ),
        ),
        IconButton(
          onPressed: onDown,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        ),
      ],
    );
  }

  Widget _arrow(IconData icon, StageView? dest) {
    return Listener(
      onPointerDown: (_) => AudioController.instance.suppressNextTap(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 40),
        onPressed: dest == null ? null : () => _go(dest),
      ),
    );
  }

  StageView? _left(StageView v) {
    switch (v) {
      case StageView.sofa:
        return StageView.kitchen;
      case StageView.kitchen:
        return StageView.computer;
      case StageView.door:
        return StageView.sofa;
      case StageView.computer:
        return StageView.door;
      case StageView.sofaTop:
      case StageView.kitchenTop:
      case StageView.doorTop:
      case StageView.computerTop:
        return null;
    }
    //  return null;
  }

  StageView? _right(StageView v) {
    switch (v) {
      case StageView.sofa:
        return StageView.door;
      case StageView.kitchen:
        return StageView.sofa;
      case StageView.door:
        return StageView.computer;
      case StageView.computer:
        return StageView.kitchen;
      case StageView.sofaTop:
      case StageView.kitchenTop:
      case StageView.doorTop:
      case StageView.computerTop:
        return null;
    }
    // return null;
  }

  bool _isTop(StageView v) =>
      v == StageView.sofaTop ||
      v == StageView.kitchenTop ||
      v == StageView.doorTop ||
      v == StageView.computerTop;

  StageView? _topOf(StageView v) {
    switch (v) {
      case StageView.sofa:
        return StageView.sofaTop;
      case StageView.kitchen:
        return StageView.kitchenTop;
      case StageView.door:
        return StageView.doorTop;
      case StageView.computer:
        return StageView.computerTop;
      case StageView.sofaTop:
      case StageView.kitchenTop:
      case StageView.doorTop:
      case StageView.computerTop:
        return null;
    }
  }

  StageView? _baseOf(StageView v) {
    switch (v) {
      case StageView.sofaTop:
        return StageView.sofa;
      case StageView.kitchenTop:
        return StageView.kitchen;
      case StageView.doorTop:
        return StageView.door;
      case StageView.computerTop:
        return StageView.computer;
      case StageView.sofa:
      case StageView.kitchen:
      case StageView.door:
      case StageView.computer:
        return null;
    }
  }

// -----------------------------------------------------------------
// Inventory
// -----------------------------------------------------------------
  Widget _inventoryColumn() {
    final pageStart = _inventoryPage * 5;
    final visible = _inventory.skip(pageStart).take(5).toList();
    final firstBatchFull = _inventory.take(5).every((item) => item != null);
    final secondBatchHasItems = _inventory.skip(5).any((item) => item != null);
    final showNextArrow =
        _inventoryPage == 0 && (firstBatchFull || _secondInventoryBatchVisible);
    final showBackArrow = _inventoryPage == 1;

    return SizedBox(
      width: 90,
      child: Padding(
        padding: const EdgeInsets.only(left: 25, top: 8, bottom: 8),
        child: Column(
          children: [
            for (var slot in visible)
              GestureDetector(
                onDoubleTap: slot == null
                    ? null
                    : () {
                        if (slot.id.startsWith('clue') ||
                            slot.id == 'fullclue' ||
                            slot.id == 'heart') {
                          _showInventoryImage(slot);
                        }
                      },
                onTap: slot == null
                    ? null
                    : () {
                        setState(() {
                          _selectedItemId =
                              _selectedItemId == slot.id ? null : slot.id;
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: 599,
                  height: 59,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(220, 229, 168, 140),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 202, 202, 202),
                      width: 1.0,
                    ),
                  ),
                  child: slot == null
                      ? null
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                  sigmaX: 2.2,
                                  sigmaY: 2.2,
                                ),
                                child: slot.id == 'heart'
                                    ? _shakingHeart(404)
                                    : FadedAssetImage(
                                        slot.asset,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),
                            if (_selectedItemId == slot.id)
                              Container(color: Colors.black.withOpacity(0.48)),
                          ],
                        ),
                ),
              ),
            if (showNextArrow || showBackArrow)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: Icon(
                      showBackArrow
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        if (showBackArrow) {
                          _inventoryPage = 0;
                          if (!secondBatchHasItems) {
                            _secondInventoryBatchVisible = false;
                          }
                        } else {
                          _secondInventoryBatchVisible = true;
                          _inventoryPage = 1;
                        }
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

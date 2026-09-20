import 'package:flutter/material.dart';
import '../app_state.dart';
import '../audio/audio_controller.dart';
import '../navigation/route_observer.dart';
import '../settings/setting.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'stage2_scene.dart';
//import 'stage2_intro.dart';
import '../database/stage2/stage2_subscenes.dart';
import '../start.dart';
import 'blur.dart';
import 'hint.dart';
import '../puzzle.dart';
import 'puzzle2.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class _InventoryItem {
  final String id;
  final String asset;

  const _InventoryItem(this.id, this.asset);
}

class Stage2RoomScreen extends StatefulWidget {
  const Stage2RoomScreen({super.key});

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
  State<Stage2RoomScreen> createState() => _Stage2RoomScreenState();
}

class _Stage2RoomScreenState extends State<Stage2RoomScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  StageView _view = StageView.sofa;
  int _inventoryPage = 0;
  final List<_InventoryItem?> _inventory =
      List<_InventoryItem?>.filled(10, null);
  bool _secondInventoryBatchVisible = false;
  static const _blurAsset = 'assets/images/blur.png';
  static const double _sceneWidth = Stage2PuzzleLayout.sceneWidth;
  static const double _sceneHeight = Stage2PuzzleLayout.sceneHeight;
  bool _lightsOn = true;
  bool _uvLightOn = false;
  String? _selectedItemId;
  bool _final11Collected = false;
  bool _frame1FinalPlaced = false;
  bool _frame1Glow = false;
  bool _final21Raised = false;
  bool _final21Collected = false;
  bool _final23Revealed = false;
  bool _frame2Final22Revealed = false;
  bool _frame2Final22Collected = false;
  bool _final23Collected = false;
  bool _final24Revealed = false;
  bool _final24Collected = false;
  bool _frame2Final21Placed = false;
  bool _frame2Final22Placed = false;
 // bool _front1Toggled = false;
  bool _frame2Final23Placed = false;
  bool _frame2Final24Placed = false;
  bool _frame2Glow = false;
  bool _frame2RewardCollected = false;
  bool _heartPlacedOnDoor = false;
  bool _doorHeartGlow = false;
  bool _front1Solved = false;
  bool _front1Open = false;
  bool _laptopSolved = false;
  bool _logic1Collected = false;
  bool _logic2Collected = false;
  bool _logic3Collected = false;
  bool _logic4Collected = false;
  final Set<String> _hintPlacedLogic = {};
  final Map<String, Offset> _dragOffsets = {};
  bool _routeSubscribed = false;

  bool get _allFrame2PiecesPlaced =>
      _frame2Final21Placed &&
      _frame2Final22Placed &&
      _frame2Final23Placed &&
      _frame2Final24Placed;

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

  static const Offset _hintBarrierOffset = Stage2PuzzleLayout.hintBarrierOffset;
  static const double _hintBarrierSize = Stage2PuzzleLayout.hintBarrierSize;

  // Faucet water overlay placement. Edit left/top to move ft1.png.
  static const double _ft1CloseupLeft = Stage2PuzzleLayout.ft1CloseupLeft;
  static const double _ft1CloseupTop = Stage2PuzzleLayout.ft1CloseupTop;
  static const double _ft1CloseupWidth = Stage2PuzzleLayout.ft1CloseupWidth;
  static const double _ft1CloseupHeight = Stage2PuzzleLayout.ft1CloseupHeight;

  @override
  void initState() {
    super.initState();
    AudioController.instance.playMusic(AppState.stageMusic);
    AppState.instance.setCurrentStage(2);
    Stage2RoomScreen.introSeen = AppState.instance.stageIntroSeen(2);
    Stage2RoomScreen.postIntroDialogShown =
        AppState.instance.stagePostIntroDialogShown(2);
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.15,
      upperBound: 0.28,
    )..repeat(reverse: true);
    _restoreProgress();
    _syncWaterLoopWithFt1();

    /*if (!Stage2RoomScreen.introSeen) {
      Future.delayed(Duration.zero, () {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const Stage2IntroScreen()),
        );
      });
      Stage2RoomScreen.introSeen = true;
      AppState.instance.setStageIntroSeen(2, true);
    } else if (!Stage2RoomScreen.postIntroDialogShown)*/
    {
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
                      "ohh.... I'm back again...",
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
        Stage2RoomScreen.postIntroDialogShown = true;
        AppState.instance.setStagePostIntroDialogShown(2, true);
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (Stage2RoomScreen._discardNextSave) {
      Stage2RoomScreen._discardNextSave = false;
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
    final saved = Stage2RoomScreen._savedProgress;
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
    _uvLightOn = saved['uvLightOn'] as bool? ?? false;
    _selectedItemId = saved['selectedItemId'] as String?;
    _final11Collected = saved['final11Collected'] as bool? ?? false;
    _frame1FinalPlaced = saved['frame1FinalPlaced'] as bool? ?? false;
    _frame1Glow = saved['frame1Glow'] as bool? ?? false;
    _final21Raised = saved['final21Raised'] as bool? ?? false;
    _final21Collected = saved['final21Collected'] as bool? ?? false;
    _final23Revealed = saved['final22Collected'] as bool? ?? false;
    _frame2Final22Revealed = saved['lampFinal22Revealed'] as bool? ?? false;
    _frame2Final22Collected = saved['lampFinal22Collected'] as bool? ?? false;
    _final23Collected = saved['final23Collected'] as bool? ?? false;
    _final24Revealed = saved['final24Revealed'] as bool? ?? false;
    _final24Collected = saved['final24Collected'] as bool? ?? false;
    _frame2Final21Placed = saved['frame2Final21Placed'] as bool? ?? false;
    _frame2Final22Placed = saved['frame2Final22Placed'] as bool? ?? false;
    _frame2Final23Placed = saved['frame2Final23Placed'] as bool? ?? false;
    _frame2Final24Placed = saved['frame2Final24Placed'] as bool? ?? false;
    _frame2Glow = saved['frame2Glow'] as bool? ?? false;
    _frame2RewardCollected = saved['frame2RewardCollected'] as bool? ?? false;
    _heartPlacedOnDoor = saved['heartPlacedOnDoor'] as bool? ?? false;
    _doorHeartGlow = saved['doorHeartGlow'] as bool? ?? false;
    _front1Solved = saved['front1Solved'] as bool? ?? false;
    _front1Open = saved['front1Open'] as bool? ?? false;
    _laptopSolved = saved['laptopSolved'] as bool? ?? false;
    _logic1Collected = saved['logic1Collected'] as bool? ?? false;
    _logic2Collected = saved['logic2Collected'] as bool? ?? false;
    _logic3Collected = saved['logic3Collected'] as bool? ?? false;
    _logic4Collected = saved['logic4Collected'] as bool? ?? false;
    _hintPlacedLogic
      ..clear()
      ..addAll(Set<String>.from(saved['hintPlacedLogic'] as Set));
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
    Stage2RoomScreen._savedProgress = {
      'view': _view,
      'inventoryPage': _inventoryPage,
      'inventory': List<_InventoryItem?>.from(_inventory),
      'secondInventoryBatchVisible': _secondInventoryBatchVisible,
      'lightsOn': _lightsOn,
      'uvLightOn': _uvLightOn,
      'selectedItemId': _selectedItemId,
      'final11Collected': _final11Collected,
      'frame1FinalPlaced': _frame1FinalPlaced,
      'frame1Glow': _frame1Glow,
      'final21Raised': _final21Raised,
      'final21Collected': _final21Collected,
      'final23Revealed': _final23Revealed,
      'lampFinal22Revealed': _frame2Final22Revealed,
      'lampFinal22Collected': _frame2Final22Collected,
      'final23Collected': _final23Collected,
      'final24Revealed': _final24Revealed,
      'final24Collected': _final24Collected,
      'frame2Final21Placed': _frame2Final21Placed,
      'frame2Final22Placed': _frame2Final22Placed,
      'frame3Final23Placed': _frame2Final23Placed,
      'frame2Final24Placed': _frame2Final24Placed,
      'frame2Glow': _frame2Glow,
      'frame2RewardCollected': _frame2RewardCollected,
      'heartPlacedOnDoor': _heartPlacedOnDoor,
      'doorHeartGlow': _doorHeartGlow,
      'front1Solved': _front1Solved,
      'front1Open': _front1Open,
      'laptopSolved': _laptopSolved,
      'logic1Collected': _logic1Collected,
      'logic2Collected': _logic2Collected,
      'logic3Collected': _logic3Collected,
      'logic4Collected': _logic4Collected,
      'hintPlacedLogic': Set<String>.from(_hintPlacedLogic),
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
                      _airySilenceOverlay(),
                      _floatingDots(),
                      if (_activeSub != null) _buildSubScene(_activeSub!),
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

          //======================================================================================================================================
//======================================================================================================================================
          if (_view == StageView.door && _heartPlacedOnDoor)
            Positioned(
              left: 220,
              top: 123,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const StartScreen(progress: 3),
                  ),
                ),
                child: FadedAssetImage(
                  'assets/images/door2.png',
                  width: 115,
                ),
              ),
            ),
          if (!_lightsOn && _isTop(_view)) ..._darkTopPuzzleWidgets(),
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
          if (_view == StageView.sofa) ..._sofaFrame2PlacedWidgets(),
          if (_view == StageView.kitchen && _front1Open && !_frame2Final22Revealed)
            Positioned(
              left: Stage2PuzzleLayout.final23Offset.dx,
              top: Stage2PuzzleLayout.final23Offset.dy,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem(
                      'final-2-2',
                      Stage2PuzzleAssets.final22,
                    ),
                    allowDuplicate: true,
                  );
                  setState(() => _frame2Final22Revealed = true);
                },
                child: FadedAssetImage(
                  Stage2PuzzleAssets.final22,
                  width: Stage2PuzzleLayout.final23Width,
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
      setState(() {
        _lightsOn = !_lightsOn;
        if (_lightsOn) _uvLightOn = false;
      });
      return;
    }
    if (id == 'k-door1') {
      if (_front1Solved) {
        setState(() => _front1Open = !_front1Open);
      }
      return;
    }
    if (id == 'k-door2') {
      return;
    }
    if (id == 'sofa-frame1' &&
        _selectedItemId == 'final-1-1' &&
        !_frame1FinalPlaced) {
      _placeFinal11InFrame1();
      return;
    }
    if (id == 'sofa-frame2' && _placeSelectedFrame2Piece()) {
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

  void _placeFinal11InFrame1() {
    setState(() {
      _frame1FinalPlaced = true;
      _selectedItemId = null;
      _removeInventoryItem('final-1-1');
      _frame1Glow = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _frame1Glow = false);
    });
  }

  bool _canToggleStageHotspot(String id) {
    if (id == 'k-door2' || id == 'c-door1') {
      _showLockedMessage();
      return false;
    }
    if (id == 'k-door1' && !_front1Solved) {
      _showFront1Puzzle();
      return false;
    }
    return true;
  }

  List<Widget> _darkTopPuzzleWidgets() {
    final hiddenFinal21 = !_final21Collected
        ? Positioned(
            left: (_final21Raised
                    ? Stage2PuzzleLayout.darkTopRaisedOffset
                    : Stage2PuzzleLayout.darkTopImageOffset)
                .dx,
            top: (_final21Raised
                    ? Stage2PuzzleLayout.darkTopRaisedOffset
                    : Stage2PuzzleLayout.darkTopImageOffset)
                .dy,
            child: GestureDetector(
              onTap: _final21Raised
                  ? () {
                      _addInventoryItem(
                        const _InventoryItem(
                          'final-2-1',
                          Stage2PuzzleAssets.final21,
                        ),
                      );
                      setState(() => _final21Collected = true);
                    }
                  : null,
              child: FadedAssetImage(
                Stage2PuzzleAssets.final21,
                width: _final21Raised
                    ? Stage2PuzzleLayout.darkTopRaisedWidth
                    : Stage2PuzzleLayout.darkTopImageWidth,
              ),
            ),
          )
        : null;

    return [
      if (!_final21Raised && hiddenFinal21 != null) hiddenFinal21,
      const Positioned(
        left: 220,
        top: 40,
        child: FadedAssetImage('assets/images/topsofa1.png', width: 120),
      ),
      Positioned(
        left: 220,
        top: 40,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: () => setState(() => _final21Raised = true),
          child: const SizedBox(
            width: 120,
            height: 120,
          ),
        ),
      ),
      if (_final21Raised && hiddenFinal21 != null) hiddenFinal21,
    ];
  }

  List<Widget> _sofaFrame2PlacedWidgets() {
    return [
      if (_frame2Final21Placed)
        _placedSofaPiece(
          Stage2PuzzleLayout.sofa21Offset,
          Stage2PuzzleAssets.final21,
        ),
      if (_frame2Final22Placed)
        _placedSofaPiece(
          Stage2PuzzleLayout.sofa22Offset,
          Stage2PuzzleAssets.final22,
        ),
      if (_frame2Final23Placed)
        _placedSofaPiece(
          Stage2PuzzleLayout.sofa23Offset,
          Stage2PuzzleAssets.final23,
        ),
      if (_frame2Final24Placed)
        _placedSofaPiece(
          Stage2PuzzleLayout.sofa24Offset,
          Stage2PuzzleAssets.final24,
        ),
    ];
  }

  Widget _placedSofaPiece(Offset offset, String asset) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          boxShadow: _frame2Glow
              ? const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: FadedAssetImage(
          asset,
          width: Stage2PuzzleLayout.sofaPieceWidth,
        ),
      ),
    );
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
                  _placeSelectedLogicOnHint();
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
          if (scene.id == 'c-table' && _uvLightOn)
            Positioned(
              left: Stage2PuzzleLayout.uvLightOffset.dx,
              top: Stage2PuzzleLayout.uvLightOffset.dy,
              child: IgnorePointer(
                child: Container(
                  width: Stage2PuzzleLayout.uvLightWidth,
                  height: Stage2PuzzleLayout.uvLightHeight,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB9A7FF).withOpacity(0.48),
                        const Color(0xFF735BFF).withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (scene.id == 'c-table' &&
              _frame2Final22Revealed &&
              !_frame2Final22Collected)
            Positioned(
              left: Stage2PuzzleLayout.final22Offset.dx,
              top: Stage2PuzzleLayout.final22Offset.dy,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem(
                      'lamp-final-2-2',
                      Stage2PuzzleAssets.final22,
                    ),
                  );
                  setState(() => _frame2Final22Collected = true);
                },
                child: AnimatedBuilder(
                  animation: _blinkCtrl,
                  builder: (context, child) {
                    final pulse = 1 + math.sin(_blinkCtrl.value * 24) * 0.08;
                    return Transform.scale(scale: pulse, child: child);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB9A7FF).withOpacity(0.8),
                          blurRadius: 22,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: FadedAssetImage(
                      Stage2PuzzleAssets.final22,
                      width: Stage2PuzzleLayout.final22Width,
                    ),
                  ),
                ),
              ),
            ),

//---------------------------------------------------------------------------------------------------------------------
          /*  if (scene.id == 'sofa-chair' &&
              (_subToggles['sofa-chair-pillow'] ?? false) &&
              !_final11Collected)
            Positioned(
              left: 92,
              top: 182,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem('final-1-1', PuzzleAssets.final11),
                  );
                  setState(() => _final11Collected = true);
                },

//----------------------------------------------------------------------------------------------------------------------------

                child: const PuzzleImage(
                  asset: PuzzleAssets.final11,
                  width: 70,
                ),
              ),
       /*     ),*/
          if (scene.id == 'sofa-table' &&
              (_subToggles['sofa-table-t2'] ?? false) &&
              !_hasInventoryItem('clue1'))
            Positioned(
              left: 285,
              top: 190,
              child: GestureDetector(
                onTap: () => _addClue('clue1', PuzzleAssets.clue1),
                child: const PuzzleImage(
                  asset: PuzzleAssets.clue1,
                  width: 42,
                ),
              ),
            ),
            */
          if (scene.id == 'sofa-table') ...[
            if ((_subToggles['sofa-table-t6'] ?? false) && !_logic1Collected)
              _collectiblePuzzleImage(
                Stage2PuzzleLayout.logic1Offset,
                Stage2PuzzleLayout.logicWidth,
                'logic1',
                Stage2PuzzleAssets.logic1,
                () => setState(() => _logic1Collected = true),
              ),
            if ((_subToggles['sofa-table-t4'] ?? false) && !_logic2Collected)
              _collectiblePuzzleImage(
                Stage2PuzzleLayout.logic2Offset,
                Stage2PuzzleLayout.logicWidth,
                'logic2',
                Stage2PuzzleAssets.logic2,
                () => setState(() => _logic2Collected = true),
              ),
            if (!_logic4Collected)
              _collectiblePuzzleImage(
                Stage2PuzzleLayout.logic4Offset,
                Stage2PuzzleLayout.logicWidth,
                'logic4',
                Stage2PuzzleAssets.logic4,
                () => setState(() => _logic4Collected = true),
              ),
          ],
          if (scene.id == 'sofa-chair' &&
              (_subToggles['sofa-chair-pillow'] ?? false) &&
              !_logic3Collected)
            _collectiblePuzzleImage(
              Stage2PuzzleLayout.logic3Offset,
              Stage2PuzzleLayout.logicWidth,
              'logic3',
              Stage2PuzzleAssets.logic3,
              () => setState(() => _logic3Collected = true),
            ),
          if (scene.id == 'k-1' && _front1Open && !_final23Revealed)
            Positioned(
              left: Stage2PuzzleLayout.final23Offset.dx,
              top: Stage2PuzzleLayout.final23Offset.dy,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem(
                      'final-2-2',
                      Stage2PuzzleAssets.final22,
                    ),
                  );
                  setState(() => _final23Revealed = true);
                },
                child: FadedAssetImage(
                  Stage2PuzzleAssets.final22,
                  width: Stage2PuzzleLayout.final23Width,
                ),
              ),
            ),
          if (scene.id == 'laptop-screen') ...[
            if (!_laptopSolved)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _showLaptopPuzzle,
                  child: Container(
                      color: const Color(0xFF8ED7FF).withOpacity(0.28)),
                ),
              ),
            if (_final24Revealed && !_final24Collected)
              Positioned(
                left: Stage2PuzzleLayout.final24Offset.dx,
                top: Stage2PuzzleLayout.final24Offset.dy,
                child: GestureDetector(
                  onTap: () {
                    _addInventoryItem(
                      const _InventoryItem(
                        'final-2-4',
                        Stage2PuzzleAssets.final24,
                      ),
                    );
                    setState(() => _final24Collected = true);
                  },
                  child: FadedAssetImage(
                    Stage2PuzzleAssets.final24,
                    width: Stage2PuzzleLayout.final24Width,
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
              left: Stage2PuzzleLayout.doorHeartOffset.dx,
              top: Stage2PuzzleLayout.doorHeartOffset.dy,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  boxShadow: _doorHeartGlow
                      ? const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 22,
                            spreadRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: _shakingHeart(Stage2PuzzleLayout.doorHeartWidth),
              ),
            ),
          if (scene.id == 'k-3' && _ft1Mounted)
            _ft1Overlay(
              left: _ft1CloseupLeft,
              top: _ft1CloseupTop,
              width: _ft1CloseupWidth,
              height: _ft1CloseupHeight,
            ),
          if (scene.id == 'sofa-frame1' && _frame1FinalPlaced)
            Positioned(
              left: 205,
              top: 102,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(2),
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
                child: const PuzzleImage(
                  asset: PuzzleAssets.final11,
                  width: 48,
                ),
              ),
            ),
          if (scene.id == 'sofa-frame2') ..._frame2CloseupWidgets(),
          if (scene.id == 'c-hint') ..._hintLogicWidgets(),
        ],
      ),
    );
  }

  Widget _collectiblePuzzleImage(
    Offset offset,
    double width,
    String id,
    String asset,
    VoidCallback markCollected,
  ) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTap: () {
          _addInventoryItem(_InventoryItem(id, asset));
          markCollected();
        },
        child: FadedAssetImage(asset, width: width),
      ),
    );
  }

  List<Widget> _frame2CloseupWidgets() {
    final widgets = <Widget>[
      if (_frame2Final21Placed)
        _placedFrame2Piece(
          Stage2PuzzleLayout.frame21Offset,
          Stage2PuzzleAssets.final21,
        ),
      if (_frame2Final22Placed)
        _placedFrame2Piece(
          Stage2PuzzleLayout.frame22Offset,
          Stage2PuzzleAssets.final22,
        ),
      if (_frame2Final23Placed)
        _placedFrame2Piece(
          Stage2PuzzleLayout.frame23Offset,
          Stage2PuzzleAssets.final23,
        ),
      if (_frame2Final24Placed)
        _placedFrame2Piece(
          Stage2PuzzleLayout.frame24Offset,
          Stage2PuzzleAssets.final24,
        ),
    ];

    if (_allFrame2PiecesPlaced && !_frame2RewardCollected) {
      widgets.addAll([
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.black.withOpacity(0.28)),
          ),
        ),
        Positioned(
          left: Stage2PuzzleLayout.heartRewardOffset.dx,
          top: Stage2PuzzleLayout.heartRewardOffset.dy,
          child: GestureDetector(
            onTap: () {
              _addInventoryItem(
                const _InventoryItem('heart', PuzzleAssets.heart),
              );
              setState(() => _frame2RewardCollected = true);
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
              child: _shakingHeart(Stage2PuzzleLayout.heartRewardWidth),
            ),
          ),
        ),
      ]);
    }

    return widgets;
  }

  Widget _placedFrame2Piece(Offset offset, String asset) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          boxShadow: _frame2Glow
              ? const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 18,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: FadedAssetImage(
          asset,
          width: Stage2PuzzleLayout.framePieceWidth,
        ),
      ),
    );
  }

  Widget _shakingHeart(double width) {
    return FadedAssetImage(PuzzleAssets.heart, width: width);
  }

  List<Widget> _hintLogicWidgets() {
    return [
      for (final id in _hintPlacedLogic)
        _draggablePlacedImage(
          keyId: 'stage2-hint-$id',
          asset: _assetForInventoryId(id),
          initialOffset: _defaultHintLogicOffset(id),
          width: Stage2PuzzleLayout.hintLogicWidth,
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

  Offset _defaultHintLogicOffset(String id) {
    switch (id) {
      case 'logic1':
        return Stage2PuzzleLayout.hintLogic1Offset;
      case 'logic2':
        return Stage2PuzzleLayout.hintLogic2Offset;
      case 'logic3':
        return Stage2PuzzleLayout.hintLogic3Offset;
      case 'logic4':
        return Stage2PuzzleLayout.hintLogic4Offset;
      default:
        return const Offset(160, 240);
    }
  }

  String _assetForInventoryId(String id) {
    switch (id) {
      case 'final-2-1':
        return Stage2PuzzleAssets.final21;
      case 'final-2-2':
        return Stage2PuzzleAssets.final22;
      case 'final-2-3':
        return Stage2PuzzleAssets.final23;
      case 'final-2-4':
        return Stage2PuzzleAssets.final24;
      case 'logic1':
        return Stage2PuzzleAssets.logic1;
      case 'logic2':
        return Stage2PuzzleAssets.logic2;
      case 'logic3':
        return Stage2PuzzleAssets.logic3;
      case 'logic4':
        return Stage2PuzzleAssets.logic4;
      case 'heart':
        return PuzzleAssets.heart;
      default:
        return '';
    }
  }


  bool _placeSelectedFrame2Piece() {
    switch (_selectedItemId) {
      case 'final-2-1':
        if (!_frame2Final21Placed) {
          _placeFrame2Piece('final-2-1');
          return true;
        }
        break;
      case 'final-2-2':
        if (!_frame2Final22Placed) {
          _placeFrame2Piece('final-2-2');
          return true;
        }
        break;
      case 'final-2-3':
        if (!_frame2Final23Placed) {
          _placeFrame2Piece('final-2-3');
          return true;
        }
        break;
      case 'final-2-4':
        if (!_frame2Final24Placed) {
          _placeFrame2Piece('final-2-4');
          return true;
        }
        break;
    }
    return false;
  }

  void _placeFrame2Piece(String id) {
    setState(() {
      if (id == 'final-2-1') _frame2Final21Placed = true;
      if (id == 'final-2-2') _frame2Final22Placed = true;
      if (id == 'final-2-3') _frame2Final23Placed = true;
      if (id == 'final-2-4') _frame2Final24Placed = true;
      _selectedItemId = null;
      _removeInventoryItem(id);
      _frame2Glow = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _frame2Glow = false);
    });
  }

  void _placeSelectedLogicOnHint() {
    final id = _selectedItemId;
    if (id != 'logic1' && id != 'logic2' && id != 'logic3' && id != 'logic4') {
      return;
    }
    setState(() {
      _hintPlacedLogic.add(id!);
      _removeInventoryItem(id);
      _selectedItemId = null;
    }); 
  }

  Widget _subButton(String sceneId, SubHotspot ov) {
    if (sceneId == 'sofa-frame1' &&
        (_frame1FinalPlaced && ov.id == 'frame1-01-1')) {
      return const SizedBox.shrink();
    }
    if (sceneId == 'sofa-frame2' &&
        ((_frame2Final21Placed && ov.id == 'frame2-02-1') ||
            (_frame2Final22Placed && ov.id == 'frame2-02-2') ||
            (_frame2Final23Placed && ov.id == 'frame2-02-3') ||
            (_frame2Final24Placed && ov.id == 'frame2-02-4'))) {
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
          if (sceneId == 'sofa-frame2' && _placeSelectedFrame2Piece()) {
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
          if (sceneId == 'c-table' && ov.id == 'lamp' && !_lightsOn) {
            setState(() {
              _uvLightOn = !_uvLightOn;
              if (_uvLightOn) _frame2Final22Revealed = true;
            });
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
          if (ov.id == 'clue2') {
            _addClue('clue2', PuzzleAssets.clue2);
            return;
          }
          if (sceneId == 'sofa-frame1' &&
              _selectedItemId == 'final-1-1' &&
              !_frame1FinalPlaced) {
            _placeFinal11InFrame1();
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
        _doorHeartGlow = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _doorHeartGlow = false);
      });
      return;
    }
    if (_heartPlacedOnDoor) {
      AppState.instance.unlockStage(3);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StartScreen(progress: 3)),
      );
      return;
    }
    _doorCloseupTapCount += 1;
    if (_doorCloseupTapCount >= 2) {
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

  Widget _airySilenceOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEAF7FF).withOpacity(0.18),
              const Color(0xFFC8EAF2).withOpacity(0.08),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
      ),
    );
  }

  void _addClue(String id, String asset) {
    if (_hasInventoryItem('fullclue') || _hasInventoryItem(id)) return;

    _addInventoryItem(_InventoryItem(id, asset));
  }

  void _mergeCluesFromInventory(String pressedId) {
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

  void _addInventoryItem(
    _InventoryItem item, {
    bool allowDuplicate = false,
  }) {
    if (!allowDuplicate && _hasInventoryItem(item.id)) return;

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

  void _showFront1Puzzle() {
    final shapes = [
      'square',
      'triangle',
      'star',
      'heart',
      'down',
      'circle',
      'asterisk',
    ];
    final labels = {
      'square': Icons.crop_square,
      'triangle': Icons.change_history,
      'star': Icons.star_border,
      'heart': Icons.favorite_border,
      'down': Icons.change_history,
      'circle': Icons.circle_outlined,
      'asterisk': Icons.close,
    };
    final values = [0, 0, 0, 0, 0];

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => StatefulBuilder(
        builder: (context, setPuzzleState) {
          final solved = shapes[values[0]] == 'triangle' &&
              shapes[values[1]] == 'circle' &&
              shapes[values[2]] == 'asterisk' &&
              shapes[values[3]] == 'triangle' &&
              shapes[values[4]] == 'heart';

          return Dialog(
            backgroundColor: const Color(0xFFE9E9E9),
            child: SizedBox(
              width: 640,
              height: 270,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < 5; i++)
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
                      if (solved) {
                        setState(() => _front1Solved = true);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
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

  void _showLaptopPuzzle() {
    final values = [0, 0, 0, 0];
    final choices = [1, 2, 3, 0];

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => StatefulBuilder(
        builder: (context, setPuzzleState) {
          final solved = choices[values[0]] == 1 &&
              choices[values[1]] == 0 &&
              choices[values[2]] == 1 &&
              choices[values[3]] == 1;

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
                          value: choices[values[i]],
                          onUp: () => setPuzzleState(() {
                            values[i] = (values[i] + 1) % choices.length;
                          }),
                          onDown: () => setPuzzleState(() {
                            values[i] = (values[i] - 1 + choices.length) %
                                choices.length;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (solved) {
                        setState(() {
                          _laptopSolved = true;
                          _final24Revealed = true;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
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
                onTap: slot == null
                    ? null
                    : () {
                        if ((slot.id == 'clue1' || slot.id == 'clue2') &&
                            _hasInventoryItem(
                              slot.id == 'clue1' ? 'clue2' : 'clue1',
                            )) {
                          _mergeCluesFromInventory(slot.id);
                          return;
                        }
                        if (slot.id == 'clue1' ||
                            slot.id == 'clue2' ||
                            slot.id == 'fullclue' ||
                            slot.id == 'heart') {
                          _showInventoryImage(slot);
                        }
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
                                    ? _shakingHeart(44)
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

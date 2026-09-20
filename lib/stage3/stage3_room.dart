import 'package:flutter/material.dart';
import '../app_state.dart';
import '../audio/audio_controller.dart';
import '../navigation/route_observer.dart';
import '../settings/setting.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'stage3_scene.dart';
//import 'stage3_intro.dart';
import '../database/stage3/stage3_subscenes.dart';
import '../start.dart';
import 'blur.dart';
import 'hint.dart';
import '../puzzle.dart';
import 'endingintro.dart';
import 'puzzle3.dart';
import 'package:fragment/widgets/faded_asset_image.dart';

class _InventoryItem {
  final String id;
  final String asset;

  const _InventoryItem(this.id, this.asset);
}

class Stage3RoomScreen extends StatefulWidget {
  const Stage3RoomScreen({super.key});

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
  State<Stage3RoomScreen> createState() => _Stage3RoomScreenState();
}

class _Stage3RoomScreenState extends State<Stage3RoomScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  StageView _view = StageView.sofa;
  int _inventoryPage = 0;
  final List<_InventoryItem?> _inventory =
      List<_InventoryItem?>.filled(10, null);
  bool _secondInventoryBatchVisible = false;
  static const _blurAsset = 'assets/images/blur.png';
  static const double _sceneWidth = Stage3PuzzleLayout.sceneWidth;
  static const double _sceneHeight = Stage3PuzzleLayout.sceneHeight;
  bool _lightsOn = true;
  String? _selectedItemId;
  bool _final11Collected = false;
  bool _frame1FinalPlaced = false;
  bool _frame1Glow = false;
  bool _final31Collected = false;
  bool _final32Collected = false;
  bool _final33Collected = false;
  bool _final34Collected = false;
  bool _frame3Final31Placed = false;
  bool _frame3Final32Placed = false;
  bool _frame3Final33Placed = false;
  bool _frame3Final34Placed = false;
  bool _frame3Glow = false;
  bool _frame3RewardCollected = false;
  bool _heartPlacedOnDoor = false;
  bool _stageComplete = false;
  bool _table2Unlocked = false;
  bool _front2Unlocked = false;
  bool _computerDoorPuzzleSolved = false;
  bool _computerDoorOpenedOnce = false;
  bool _screenPuzzleSolved = false;
  bool _key1Collected = false;
  bool _key2Collected = false;
  bool _binaryTableCollected = false;
  bool _binaryClockCollected = false;
  bool _rockCollected = false;
  bool _matchCollected = false;
  bool _potCollected = false;
  bool _potAtFaucet = false;
  bool _potHasWater = false;
  bool _rockInPot = false;
  bool _fireStarted = false;
  bool _potatoReady = false;
  bool _potatoCollected = false;
  bool _potatoInOven = false;
  int _potatoBakeTaps = 0;
  int _vaseTapCount = 0;
  int _clockArrowTurns = 0;
  final Map<String, Offset> _dragOffsets = {};
  bool _routeSubscribed = false;

  bool get _allFrame3PiecesPlaced =>
      _frame3Final31Placed &&
      _frame3Final32Placed &&
      _frame3Final33Placed &&
      _frame3Final34Placed;

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

  static const Offset _hintBarrierOffset = Stage3PuzzleLayout.hintBarrierOffset;
  static const double _hintBarrierSize = Stage3PuzzleLayout.hintBarrierSize;

  // Faucet water overlay placement. Edit left/top to move ft1.png.
  static const double _ft1CloseupLeft = Stage3PuzzleLayout.ft1CloseupLeft;
  static const double _ft1CloseupTop = Stage3PuzzleLayout.ft1CloseupTop;
  static const double _ft1CloseupWidth = Stage3PuzzleLayout.ft1CloseupWidth;
  static const double _ft1CloseupHeight = Stage3PuzzleLayout.ft1CloseupHeight;


  @override
  void initState() {
    super.initState();
    AudioController.instance.playMusic(AppState.stageMusic);
    AppState.instance.setCurrentStage(3);
    Stage3RoomScreen.introSeen = AppState.instance.stageIntroSeen(3);
    Stage3RoomScreen.postIntroDialogShown =
        AppState.instance.stagePostIntroDialogShown(3);
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.15,
      upperBound: 0.28,
    )..repeat(reverse: true);
    _restoreProgress();
    _syncWaterLoopWithFt1();

    if (!Stage3RoomScreen.introSeen) {
      Future.delayed(Duration.zero, () {
      //  Navigator.push(
          // ignore: use_build_context_synchronously
         // context,
        //  MaterialPageRoute(builder: (_) => const Stage3IntroScreen()),
       // );
      });
      Stage3RoomScreen.introSeen = true;
      AppState.instance.setStageIntroSeen(3, true);
    } else if (!Stage3RoomScreen.postIntroDialogShown) {
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
        Stage3RoomScreen.postIntroDialogShown = true;
        AppState.instance.setStagePostIntroDialogShown(3, true);
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (Stage3RoomScreen._discardNextSave) {
      Stage3RoomScreen._discardNextSave = false;
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
    final saved = Stage3RoomScreen._savedProgress;
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
    _frame1FinalPlaced = saved['frame1FinalPlaced'] as bool? ?? false;
    _frame1Glow = saved['frame1Glow'] as bool? ?? false;
    _final31Collected = saved['final31Collected'] as bool? ?? false;
    _final32Collected = saved['final32Collected'] as bool? ?? false;
    _final33Collected = saved['final33Collected'] as bool? ?? false;
    _final34Collected = saved['final34Collected'] as bool? ?? false;
    _frame3Final31Placed = saved['frame3Final31Placed'] as bool? ?? false;
    _frame3Final32Placed = saved['frame3Final32Placed'] as bool? ?? false;
    _frame3Final33Placed = saved['frame3Final33Placed'] as bool? ?? false;
    _frame3Final34Placed = saved['frame3Final34Placed'] as bool? ?? false;
    _frame3Glow = saved['frame3Glow'] as bool? ?? false;
    _frame3RewardCollected = saved['frame3RewardCollected'] as bool? ?? false;
    _heartPlacedOnDoor = saved['heartPlacedOnDoor'] as bool? ?? false;
    _stageComplete = saved['stageComplete'] as bool? ?? false;
    _table2Unlocked = saved['table2Unlocked'] as bool? ?? false;
    _front2Unlocked = saved['front2Unlocked'] as bool? ?? false;
    _computerDoorPuzzleSolved =
        saved['computerDoorPuzzleSolved'] as bool? ?? false;
    _computerDoorOpenedOnce = saved['computerDoorOpenedOnce'] as bool? ?? false;
    _screenPuzzleSolved = saved['screenPuzzleSolved'] as bool? ?? false;
    _key1Collected = saved['key1Collected'] as bool? ?? false;
    _key2Collected = saved['key2Collected'] as bool? ?? false;
    _binaryTableCollected = saved['binaryTableCollected'] as bool? ?? false;
    _binaryClockCollected = saved['binaryClockCollected'] as bool? ?? false;
    _rockCollected = saved['rockCollected'] as bool? ?? false;
    _matchCollected = saved['matchCollected'] as bool? ?? false;
    _potCollected = saved['potCollected'] as bool? ?? false;
    _potAtFaucet = saved['potAtFaucet'] as bool? ?? false;
    _potHasWater = saved['potHasWater'] as bool? ?? false;
    _rockInPot = saved['rockInPot'] as bool? ?? false;
    _fireStarted = saved['fireStarted'] as bool? ?? false;
    _potatoReady = saved['potatoReady'] as bool? ?? false;
    _potatoCollected = saved['potatoCollected'] as bool? ?? false;
    _potatoInOven = saved['potatoInOven'] as bool? ?? false;
    _potatoBakeTaps = saved['potatoBakeTaps'] as int? ?? 0;
    _vaseTapCount = saved['vaseTapCount'] as int? ?? 0;
    _clockArrowTurns = saved['clockArrowTurns'] as int? ?? 0;
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
    Stage3RoomScreen._savedProgress = {
      'view': _view,
      'inventoryPage': _inventoryPage,
      'inventory': List<_InventoryItem?>.from(_inventory),
      'secondInventoryBatchVisible': _secondInventoryBatchVisible,
      'lightsOn': _lightsOn,
      'selectedItemId': _selectedItemId,
      'final11Collected': _final11Collected,
      'frame1FinalPlaced': _frame1FinalPlaced,
      'frame1Glow': _frame1Glow,
      'final31Collected': _final31Collected,
      'final32Collected': _final32Collected,
      'final33Collected': _final33Collected,
      'final34Collected': _final34Collected,
      'frame3Final31Placed': _frame3Final31Placed,
      'frame3Final32Placed': _frame3Final32Placed,
      'frame3Final33Placed': _frame3Final33Placed,
      'frame3Final34Placed': _frame3Final34Placed,
      'frame3Glow': _frame3Glow,
      'frame3RewardCollected': _frame3RewardCollected,
      'heartPlacedOnDoor': _heartPlacedOnDoor,
      'stageComplete': _stageComplete,
      'table2Unlocked': _table2Unlocked,
      'front2Unlocked': _front2Unlocked,
      'computerDoorPuzzleSolved': _computerDoorPuzzleSolved,
      'computerDoorOpenedOnce': _computerDoorOpenedOnce,
      'screenPuzzleSolved': _screenPuzzleSolved,
      'key1Collected': _key1Collected,
      'key2Collected': _key2Collected,
      'binaryTableCollected': _binaryTableCollected,
      'binaryClockCollected': _binaryClockCollected,
      'rockCollected': _rockCollected,
      'matchCollected': _matchCollected,
      'potCollected': _potCollected,
      'potAtFaucet': _potAtFaucet,
      'potHasWater': _potHasWater,
      'rockInPot': _rockInPot,
      'fireStarted': _fireStarted,
      'potatoReady': _potatoReady,
      'potatoCollected': _potatoCollected,
      'potatoInOven': _potatoInOven,
      'potatoBakeTaps': _potatoBakeTaps,
      'vaseTapCount': _vaseTapCount,
      'clockArrowTurns': _clockArrowTurns,
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
                      _sciFiMysteryOverlay(),
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
          if (_view == StageView.door && _stageComplete)
            Positioned(
              left: 220,
              top: 123,
              child: GestureDetector(
                onTap: _returnToStart,
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
          if (_view == StageView.sofa) ..._sofaFrame3PlacedWidgets(),
          if (_view == StageView.computer && _computerDoorOpenedOnce) ...[
            if (!_final33Collected)
              Positioned(
                left: Stage3PuzzleLayout.comFinal33Offset.dx,
                top: Stage3PuzzleLayout.comFinal33Offset.dy,
                child: GestureDetector(
                  onTap: () {
                    _addInventoryItem(
                      const _InventoryItem(
                        'final-3-3',
                        Stage3PuzzleAssets.final33,
                      ),
                    );
                    setState(() => _final33Collected = true);
                  },
                  child: FadedAssetImage(
                    Stage3PuzzleAssets.final33,
                    width: Stage3PuzzleLayout.comFinal33Width,
                  ),
                ),
              ),
            if (!_key2Collected)
              Positioned(
                left: Stage3PuzzleLayout.key2Offset.dx,
                top: Stage3PuzzleLayout.key2Offset.dy,
                child: GestureDetector(
                  onTap: () {
                    _addInventoryItem(
                      const _InventoryItem('key2', Stage3PuzzleAssets.key2),
                    );
                    setState(() => _key2Collected = true);
                  },
                  child: FadedAssetImage(
                    Stage3PuzzleAssets.key2,
                    width: Stage3PuzzleLayout.keyWidth,
                  ),
                ),
              ),
          ],
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
    if (id == 'sofa-frame1' &&
        _selectedItemId == 'final-1-1' &&
        !_frame1FinalPlaced) {
      _placeFinal11InFrame1();
      return;
    }
    if (id == 'sofa-frame3' && _placeSelectedFrame3Piece()) {
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

  List<Widget> _sofaFrame3PlacedWidgets() {
    return [
      if (_frame3Final31Placed)
        _placedSofaPiece(
          Stage3PuzzleLayout.sofa31Offset,
          Stage3PuzzleAssets.final31,
        ),
      if (_frame3Final32Placed)
        _placedSofaPiece(
          Stage3PuzzleLayout.sofa32Offset,
          Stage3PuzzleAssets.final32,
        ),
      if (_frame3Final33Placed)
        _placedSofaPiece(
          Stage3PuzzleLayout.sofa33Offset,
          Stage3PuzzleAssets.final33,
        ),
      if (_frame3Final34Placed)
        _placedSofaPiece(
          Stage3PuzzleLayout.sofa34Offset,
          Stage3PuzzleAssets.final34,
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
          boxShadow: _frame3Glow
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
          width: Stage3PuzzleLayout.sofaPieceWidth,
        ),
      ),
    );
  }

  Widget _buildSubScene(SubScene scene) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: FadedAssetImage(
              scene.background,
              width: _sceneWidth,
              height: _sceneHeight,
              fit: BoxFit.cover,
            ),
          ),
          for (final ov in scene.overlays) _subButton(scene.id, ov),
          if (scene.id == 'door-clock')
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _handleClockTap,
              ),
            ),
          if (scene.id == 'sofa-table') ..._stage3SofaTableWidgets(),
          if (scene.id == 'sofa-frame3') ..._frame3CloseupWidgets(),
          if (scene.id == 'door-clock') ..._clockWidgets(),
          if (scene.id == 'door-main' && _heartPlacedOnDoor)
            Positioned(
              left: Stage3PuzzleLayout.doorHeartOffset.dx,
              top: Stage3PuzzleLayout.doorHeartOffset.dy,
              child: _shakingHeart(Stage3PuzzleLayout.doorHeartWidth),
            ),
          if (scene.id == 'c-table') ..._computerTableWidgets(),
          if (scene.id == 'laptop-screen') ..._laptopScreenWidgets(),
          if (scene.id == 'k-1') ..._front1Widgets(),
          if (scene.id == 'k-2') ..._front2Widgets(),
          if (scene.id == 'k-3') ..._faucetWidgets(),
          if (scene.id == 'k-4') ..._ovenWidgets(),
          if (scene.id == 'sofa-chair' &&
              (_subToggles['sofa-chair-pillow'] ?? false) &&
              !_final11Collected)
           /* Positioned(
              left: 92,
              top: 182,
              child: GestureDetector(
                onTap: () {
                  _addInventoryItem(
                    const _InventoryItem('final-1-1', PuzzleAssets.final11),
                  );
                  setState(() => _final11Collected = true);
                },*/

//----------------------------------------------------------------------------------------------------------------------------

              /*  child: const PuzzleImage(
                  asset: PuzzleAssets.final11,
                  width: 70,
                ),
              ),
            ),
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
            ),*/
          if (scene.id == 'door-main')
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleDoorCloseupTap,
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
        ],
      ),
    );
  }

  Widget _subButton(String sceneId, SubHotspot ov) {
    if (sceneId == 'sofa-frame1' &&
        (_frame1FinalPlaced && ov.id == 'frame1-01-1')) {
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
    final displayAsset = sceneId == 'sofa-table' && ov.id == 'vase'
        ? (_vaseTapCount >= 2
            ? Stage3PuzzleAssets.vase3
            : _vaseTapCount == 1
                ? Stage3PuzzleAssets.vase2
                : asset)
        : asset;
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
          child: FadedAssetImage(displayAsset, width: ov.width),
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
          if (sceneId == 'sofa-table' && ov.id == 't2') {
            if (_selectedItemId == 'key1') {
              setState(() {
                _table2Unlocked = true;
                _selectedItemId = null;
                _removeInventoryItem('key1');
              });
            }
            if (!_table2Unlocked) {
              _showLockedMessage();
              return;
            }
          }
          if (sceneId == 'sofa-table' && ov.id == 'vase') {
            setState(() {
              _vaseTapCount = (_vaseTapCount + 1).clamp(1, 3).toInt();
            });
            return;
          }
          if (canRotate) {
            setState(() => _subToggles[key] = !toggled);
            return;
          }
          if (ov.id == 't6') {
            setState(() => _subToggles[key] = !toggled);
            return;
          }
          if (ov.id == 't4') {
            _showShapePuzzle();
            return;
          }
         /* if (ov.id == 'clue2') {
            _addClue('clue2', PuzzleAssets.clue2);
            return;
          }*/
         /* if (sceneId == 'sofa-frame1' &&
              _selectedItemId == 'final-1-1' &&
              !_frame1FinalPlaced) {
            _placeFinal11InFrame1();
            return;
          }*/
          if (sceneId == 'sofa-frame3' && _placeSelectedFrame3Piece()) {
            return;
          }
          if (sceneId == 'k-3' && _handleFaucetUse(ov.id)) {
            return;
          }
          if (sceneId == 'k-4' && _handleOvenUse(ov.id)) {
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
            child: FadedAssetImage(displayAsset, width: ov.width),
          ),
        ),
      ),
    );
  }

  void _handleDoorCloseupTap() {
    if (_selectedItemId == 'heart' && !_heartPlacedOnDoor) {
      setState(() {
        _heartPlacedOnDoor = true;
        _stageComplete = true;
        _selectedItemId = null;
        _removeInventoryItem('heart');
      });
      return;
    }
    if (_heartPlacedOnDoor) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EndingIntroScreen()),
      );
      return;
    }
    _doorCloseupTapCount += 1;
    if (_doorCloseupTapCount >= 2) {
      _doorCloseupTapCount = 0;
      _showLockedMessage();
    }
  }

  void _handleClockTap() {
    if (_clockArrowTurns != 0 || _binaryClockCollected) return;
    setState(() {
      _doorCloseupTapCount = (_doorCloseupTapCount + 1).clamp(0, 2).toInt();
    });
  }

  bool _handleFaucetUse(String id) {
    if (id == 'ft3' && _selectedItemId == 'pot') {
      setState(() {
        _potAtFaucet = true;
        _potHasWater = true;
        _selectedItemId = null;
        _removeInventoryItem('pot');
      });
      _showInfoMessage('Pot with water.');
      return true;
    }
    if (id == 'ft3' && _selectedItemId == 'match' && _potAtFaucet) {
      setState(() {
        _fireStarted = true;
        _selectedItemId = null;
        _removeInventoryItem('match');
      });
      _tryCookPotato();
      return true;
    }
    return false;
  }

  void _handlePotAtFaucetTap() {
    if (_selectedItemId == 'rock') {
      setState(() {
        _rockInPot = true;
        _selectedItemId = null;
        _removeInventoryItem('rock');
      });
      _tryCookPotato();
      return;
    }
    if (!_potatoReady) {
      _showInfoMessage(_fireStarted ? 'It still hot...' : 'Pot with water.');
      return;
    }
  }

  void _tryCookPotato() {
    if (!_fireStarted || !_rockInPot || !_potHasWater) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _potatoReady = true);
    });
  }

  bool _handleOvenUse(String id) {
    final ovenOpen = _subToggles['k-4-o2'] ?? false;
    if (id == 'o1' && _selectedItemId == 'potato' && ovenOpen) {
      setState(() {
        _potatoInOven = true;
        _selectedItemId = null;
        _removeInventoryItem('potato');
      });
      return true;
    }
    return false;
  }

  void _handleOvenPotatoTap() {
    if (_potatoBakeTaps >= 3) {
      _addInventoryItem(
        const _InventoryItem('final-3-4', Stage3PuzzleAssets.final34),
      );
      setState(() => _final34Collected = true);
      return;
    }
    setState(() => _potatoBakeTaps += 1);
  }

  void _returnToStart() {
    AppState.instance.unlockStage(4);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartScreen(progress: 4)),
      (route) => false,
    );
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

  bool _canToggleStageHotspot(String id) {
    if (id == 'k-door2' && !_front2Unlocked) {
      if (_selectedItemId == 'key2') {
        setState(() {
          _front2Unlocked = true;
          _selectedItemId = null;
          _removeInventoryItem('key2');
        });
        return true;
      }
      _showLockedMessage();
      return false;
    }
    if (id == 'c-door1' && !_computerDoorPuzzleSolved) {
      _showComputerDoorPuzzle();
      return false;
    }
    if (id == 'c-door1' && !_computerDoorOpenedOnce) {
      setState(() => _computerDoorOpenedOnce = true);
    }
    return true;
  }

  Widget _sciFiMysteryOverlay() {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF120B2E).withOpacity(0.36),
                  const Color(0xFF113A4A).withOpacity(0.18),
                  const Color(0xFF3B214F).withOpacity(0.26),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ScanlinePainter(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _stage3SofaTableWidgets() {
    return [
      if (_vaseTapCount >= 3 && !_final31Collected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.vaseFinal31Offset,
          Stage3PuzzleLayout.vaseFinal31Width,
          'final-3-1',
          Stage3PuzzleAssets.final31,
          () => _final31Collected = true,
        ),
      if ((_subToggles['sofa-table-t2'] ?? false) && !_final32Collected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.tableFinal32Offset,
          Stage3PuzzleLayout.tableFinal32Width,
          'final-3-2',
          Stage3PuzzleAssets.final32,
          () => _final32Collected = true,
        ),
      if ((_subToggles['sofa-table-t6'] ?? false) && !_rockCollected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.rockOffset,
          Stage3PuzzleLayout.rockWidth,
          'rock',
          Stage3PuzzleAssets.rock,
          () => _rockCollected = true,
        ),
    ];
  }

  List<Widget> _computerTableWidgets() {
    return [
      if (!_binaryTableCollected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.binaryTableOffset,
          Stage3PuzzleLayout.binaryWidth,
          'binary-table',
          Stage3PuzzleAssets.binary2,
          () => _binaryTableCollected = true,
        ),
    ];
  }

  List<Widget> _laptopScreenWidgets() {
    return [
      if (!_screenPuzzleSolved)
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _showScreenPuzzle,
            child: Container(color: const Color(0xFF8ED7FF).withOpacity(0.28)),
          ),
        ),
      if (_screenPuzzleSolved && !_key1Collected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.key1Offset,
          Stage3PuzzleLayout.keyWidth,
          'key1',
          Stage3PuzzleAssets.key1,
          () => _key1Collected = true,
        ),
    ];
  }

  List<Widget> _clockWidgets() {
    return [
      Positioned(
        left: Stage3PuzzleLayout.clockArrowOffset.dx,
        top: Stage3PuzzleLayout.clockArrowOffset.dy,
        child: GestureDetector(
          onTap: () =>
              setState(() => _clockArrowTurns = (_clockArrowTurns + 1) % 4),
          child: AnimatedRotation(
            turns: _clockArrowTurns / 4,
            duration: const Duration(milliseconds: 180),
            child: FadedAssetImage(
              'assets/images/Stage 3/arrow.png',
              width: Stage3PuzzleLayout.clockArrowWidth,
            ),
          ),
        ),
      ),
      if (_doorCloseupTapCount >= 2 &&
          _clockArrowTurns == 0 &&
          !_binaryClockCollected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.binaryClockOffset,
          Stage3PuzzleLayout.binaryWidth,
          'binary-clock',
          Stage3PuzzleAssets.binary2,
          () {
            _binaryClockCollected = true;
            _doorCloseupTapCount = 0;
          },
        ),
    ];
  }

  List<Widget> _front1Widgets() {
    return [
      if (!_potCollected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.front1PotOffset,
          Stage3PuzzleLayout.potWidth,
          'pot',
          Stage3PuzzleAssets.pot,
          () => _potCollected = true,
        ),
    ];
  }

  List<Widget> _front2Widgets() {
    return [
      if (!_potCollected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.front2PotOffset,
          Stage3PuzzleLayout.potWidth,
          'pot',
          Stage3PuzzleAssets.pot,
          () => _potCollected = true,
        ),
      if (_potCollected && !_matchCollected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.matchOffset,
          Stage3PuzzleLayout.matchWidth,
          'match',
          Stage3PuzzleAssets.match,
          () => _matchCollected = true,
        ),
    ];
  }

  List<Widget> _faucetWidgets() {
    return [
      if (_potAtFaucet)
        Positioned(
          left: Stage3PuzzleLayout.ftPotOffset.dx,
          top: Stage3PuzzleLayout.ftPotOffset.dy,
          child: GestureDetector(
            onTap: _handlePotAtFaucetTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FadedAssetImage(
                  Stage3PuzzleAssets.pot,
                  width: Stage3PuzzleLayout.potWidth,
                ),
                if (_rockInPot)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: FadedAssetImage(
                      Stage3PuzzleAssets.rock,
                      width: Stage3PuzzleLayout.rockWidth,
                    ),
                  ),
              ],
            ),
          ),
        ),
      if (_fireStarted)
        Positioned(
          left: Stage3PuzzleLayout.ftFireOffset.dx,
          top: Stage3PuzzleLayout.ftFireOffset.dy,
          child: IgnorePointer(
            child: Icon(
              Icons.local_fire_department,
              color: Colors.deepOrangeAccent.withOpacity(0.9),
              size: Stage3PuzzleLayout.fireSize,
            ),
          ),
        ),
      if (_potatoReady && !_potatoCollected)
        _collectibleStage3Image(
          Stage3PuzzleLayout.ftRockOffset,
          Stage3PuzzleLayout.rockWidth,
          'potato',
          Stage3PuzzleAssets.potato,
          () => _potatoCollected = true,
        ),
    ];
  }

  List<Widget> _ovenWidgets() {
    return [
      if (_potatoInOven && !_final34Collected)
        Positioned(
          left: Stage3PuzzleLayout.ovenFinal34Offset.dx,
          top: Stage3PuzzleLayout.ovenFinal34Offset.dy,
          child: GestureDetector(
            onTap: _handleOvenPotatoTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                boxShadow: _potatoBakeTaps >= 2
                    ? const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: FadedAssetImage(
                _potatoBakeTaps >= 3
                    ? Stage3PuzzleAssets.final34
                    : Stage3PuzzleAssets.potato,
                width: Stage3PuzzleLayout.ovenFinal34Width,
              ),
            ),
          ),
        ),
    ];
  }

  Widget _collectibleStage3Image(
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
          setState(markCollected);
        },
        child: FadedAssetImage(asset, width: width),
      ),
    );
  }

  List<Widget> _frame3CloseupWidgets() {
    final widgets = <Widget>[
      if (_frame3Final31Placed)
        _placedFrame3Piece(
          Stage3PuzzleLayout.frame31Offset,
          Stage3PuzzleAssets.final31,
        ),
      if (_frame3Final32Placed)
        _placedFrame3Piece(
          Stage3PuzzleLayout.frame32Offset,
          Stage3PuzzleAssets.final32,
        ),
      if (_frame3Final33Placed)
        _placedFrame3Piece(
          Stage3PuzzleLayout.frame33Offset,
          Stage3PuzzleAssets.final33,
        ),
      if (_frame3Final34Placed)
        _placedFrame3Piece(
          Stage3PuzzleLayout.frame34Offset,
          Stage3PuzzleAssets.final34,
        ),
    ];

    if (_allFrame3PiecesPlaced && !_frame3RewardCollected) {
      widgets.add(
        Positioned(
          left: Stage3PuzzleLayout.finalHeartOffset.dx,
          top: Stage3PuzzleLayout.finalHeartOffset.dy,
          child: GestureDetector(
            onTap: () {
              _addInventoryItem(
                const _InventoryItem('heart', Stage3PuzzleAssets.heart),
              );
              setState(() => _frame3RewardCollected = true);
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
              child: _shakingHeart(Stage3PuzzleLayout.finalHeartWidth),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _shakingHeart(double width) {
    return FadedAssetImage(Stage3PuzzleAssets.heart, width: width);
  }

  Widget _placedFrame3Piece(Offset offset, String asset) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          boxShadow: _frame3Glow
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
          width: Stage3PuzzleLayout.framePieceWidth,
        ),
      ),
    );
  }

  bool _placeSelectedFrame3Piece() {
    switch (_selectedItemId) {
      case 'final-3-1':
        if (!_frame3Final31Placed) return _placeFrame3Piece('final-3-1');
        break;
      case 'final-3-2':
        if (!_frame3Final32Placed) return _placeFrame3Piece('final-3-2');
        break;
      case 'final-3-3':
        if (!_frame3Final33Placed) return _placeFrame3Piece('final-3-3');
        break;
      case 'final-3-4':
        if (!_frame3Final34Placed) return _placeFrame3Piece('final-3-4');
        break;
    }
    return false;
  }

  bool _placeFrame3Piece(String id) {
    setState(() {
      if (id == 'final-3-1') _frame3Final31Placed = true;
      if (id == 'final-3-2') _frame3Final32Placed = true;
      if (id == 'final-3-3') _frame3Final33Placed = true;
      if (id == 'final-3-4') _frame3Final34Placed = true;
      _selectedItemId = null;
      _removeInventoryItem(id);
      _frame3Glow = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _frame3Glow = false);
    });
    return true;
  }

 /* void _addClue(String id, String asset) {
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
  }*/

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

  void _showScreenPuzzle() {
    _showNumberPuzzle(
      choices: const [1, 2, 3, 0],
      length: 5,
      answer: const [1, 0, 0, 1, 0],
      onSolved: () => setState(() => _screenPuzzleSolved = true),
    );
  }

  void _showComputerDoorPuzzle() {
    _showNumberPuzzle(
      choices: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0],
      length: 3,
      answer: const [1, 2, 2],
      onSolved: () => setState(() => _computerDoorPuzzleSolved = true),
    );
  }

  void _showNumberPuzzle({
    required List<int> choices,
    required int length,
    required List<int> answer,
    required VoidCallback onSolved,
  }) {
    final values = List<int>.filled(length, 0);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => StatefulBuilder(
        builder: (context, setPuzzleState) {
          final solved = List.generate(
            length,
            (i) => choices[values[i]] == answer[i],
          ).every((match) => match);

          return Dialog(
            backgroundColor: const Color(0xFFE9E9E9),
            child: SizedBox(
              width: length == 5 ? 600 : 420,
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < length; i++)
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
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: solved
                        ? () {
                            onSolved();
                            Navigator.of(context).pop();
                          }
                        : null,
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
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 34,
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
//-----------------------------------------------------------------------------------------------------------------------
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
          final solved = shapes[values[0]] == 'square' &&
              shapes[values[1]] == 'circle' &&
              shapes[values[2]] == 'triangle';

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
                  if (solved)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'OPEN',
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
                          //_mergeCluesFromInventory(slot.id);
                          return;
                        }
                        if (slot.id == 'clue1' ||
                            slot.id == 'clue2' ||
                            slot.id == 'fullclue' ||
                            slot.id == 'binary-table' ||
                            slot.id == 'binary-clock') {
                          _showInventoryImage(slot);
                        }
                        if (slot.id == 'pot') {
                          _showInfoMessage(
                            _potHasWater ? 'Pot with water.' : 'Empty Pot',
                          );
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

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBDEBFF).withOpacity(0.07)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

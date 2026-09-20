import 'package:flutter/material.dart';
import 'package:fragment/navigation/route_observer.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  final String assetPath;
  final double opacity;

  const VideoBackground({
    super.key,
    required this.assetPath,
    this.opacity = 0.35,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground>
    with WidgetsBindingObserver, RouteAware {
  late VideoPlayerController _controller;
  bool _isRouteActive = true;
  bool _isAppActive = true;
  bool _subscribedToRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = VideoPlayerController.asset(
      widget.assetPath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )
      ..setLooping(true)
      ..setVolume(0)
      ..addListener(_keepLoopAlive);

    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _playIfVisible();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_subscribedToRoute) return;

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribedToRoute = true;
    }
  }

  @override
  void didUpdateWidget(covariant VideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.opacity != widget.opacity && mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppActive = true;
        _playIfVisible();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _isAppActive = false;
        _pauseVideo();
        break;
    }
  }

  @override
  void didPush() {
    _isRouteActive = true;
    _playIfVisible();
  }

  @override
  void didPopNext() {
    _isRouteActive = true;
    _playIfVisible();
  }

  @override
  void didPushNext() {
    _isRouteActive = false;
    _pauseVideo();
  }

  @override
  void didPop() {
    _isRouteActive = false;
    _pauseVideo();
  }

  @override
  void dispose() {
    if (_subscribedToRoute) {
      routeObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_keepLoopAlive);
    _controller.dispose();
    super.dispose();
  }

  void _playIfVisible() {
    if (!_controller.value.isInitialized || !_isAppActive || !_isRouteActive) {
      return;
    }

    final value = _controller.value;
    if (value.duration > Duration.zero &&
        value.position >= value.duration - const Duration(milliseconds: 120)) {
      _controller.seekTo(Duration.zero);
    }

    _controller.play();
  }

  void _pauseVideo() {
    if (_controller.value.isInitialized) {
      _controller.pause();
    }
  }

  void _keepLoopAlive() {
    if (!_controller.value.isInitialized || !_isAppActive || !_isRouteActive) {
      return;
    }

    final value = _controller.value;
    if (value.duration == Duration.zero) return;

    final nearEnd =
        value.position >= value.duration - const Duration(milliseconds: 120);
    if ((value.isCompleted || (!value.isPlaying && nearEnd)) && mounted) {
      _controller.seekTo(Duration.zero);
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox.expand(
        child: ColoredBox(color: Colors.black),
      );
    }

    return RepaintBoundary(
      child: IgnorePointer(
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),

              // dark overlay
              ColoredBox(
                color: Colors.black.withOpacity(widget.opacity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'audio/audio_controller.dart';
import 'intro_screen.dart';
import 'navigation/route_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await AppState.instance.init();
  runApp(const FragmentApp());
}

Color backgroundColor() => Colors.black;

class FragmentApp extends StatelessWidget {
  const FragmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fragment',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerUp: (_) => AudioController.instance.tap(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const IntroScreen(),
    );
  }
}

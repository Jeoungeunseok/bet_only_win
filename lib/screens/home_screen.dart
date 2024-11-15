import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/game_controller.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../widgets/ripple_effect.dart';
import '../widgets/secret_settings_dialog.dart';
import '../widgets/gesture_detector_with_triple_tap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final GameController gameController;

  @override
  void initState() {
    super.initState();
    gameController = GameController(this, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetectorWithTripleTap(
      onTripleTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SecretSettingsDialog(gameController: gameController);
          },
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF98E4D8),
        body: Listener(
          onPointerDown: (event) =>
              gameController.handlePointerDown(event, context),
          onPointerMove: (event) =>
              gameController.handlePointerMove(event, context),
          onPointerUp: gameController.handlePointerUp,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ValueListenableBuilder<int?>(
                            valueListenable: gameController.countdown,
                            builder: (context, value, child) {
                              if (value != null) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }
                              return Text(
                                gameController.isSelectionComplete
                                    ? 'Touch to restart!'
                                    : 'Betting Start!',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ...gameController.activeRipples.values.map(
                      (ripple) => RippleEffectWidget(
                        ripple: ripple,
                        rippleSize: gameController.rippleSize,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 60,
                right: 20,
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: FloatingActionButton(
                    onPressed: () async {
                      final packageInfo = await PackageInfo.fromPlatform();
                      if (mounted) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return SettingsBottomSheet(
                                packageInfo: packageInfo);
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                        );
                      }
                    },
                    backgroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Color(0xFF98E4D8),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/provider/camera.dart';

const rootRoute = '/';

class CameraController extends ConsumerStatefulWidget {
  final Function pressOptions;
  final Function pressShutter;
  final Function pressSwitchCamera;
  const CameraController({
    super.key,
    required this.pressOptions,
    required this.pressShutter,
    required this.pressSwitchCamera,
  });

  @override
  ConsumerState<CameraController> createState() => _CameraControllerState();
}

class _CameraControllerState extends ConsumerState<CameraController> {
  bool enableShutterButton = true;

  @override
  Widget build(BuildContext context) {
    final camera = ref.watch(cameraProvider).value;
    final canShutter =
        enableShutterButton && camera != null && camera.isInitialized;

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.black45.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => widget.pressOptions(ref),
                  iconSize: 32,
                  icon: const Icon(Icons.apps),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: canShutter
                      ? () {
                          setState(() => enableShutterButton = false);
                          widget.pressShutter(ref).then(
                            (_) {
                              setState(() => enableShutterButton = true);
                            },
                          );
                        }
                      : null,
                  iconSize: 48,
                  icon: const Icon(Icons.camera),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () =>
                      widget.pressSwitchCamera(ref).then((_) => {}),
                  iconSize: 32,
                  icon: const Icon(Icons.cameraswitch_outlined),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

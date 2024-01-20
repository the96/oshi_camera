import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool enableShutter = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  widget.pressOptions().then((_) => {});
                },
                iconSize: 32,
                icon: const Icon(Icons.apps),
                color: Colors.white,
              ),
              IconButton(
                onPressed: enableShutter
                    ? () {
                        setState(() {
                          enableShutter = false;
                        });
                        widget.pressShutter(ref).then(
                          (_) {
                            setState(() => enableShutter = true);
                          },
                        );
                      }
                    : null,
                iconSize: 48,
                icon: const Icon(Icons.camera),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  widget.pressSwitchCamera().then((_) => {});
                },
                iconSize: 32,
                icon: const Icon(Icons.cameraswitch_outlined),
                color: Colors.white,
              ),
            ],
          ),
        )
      ],
    );
  }
}

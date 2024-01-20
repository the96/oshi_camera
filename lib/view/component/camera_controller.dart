import 'package:flutter/material.dart';

class CameraController extends StatelessWidget {
  final Future<void> pressOptions;
  final Future<void> pressShutter;
  final Future<void> pressSwitchCamera;
  const CameraController({
    super.key,
    required this.pressOptions,
    required this.pressShutter,
    required this.pressSwitchCamera,
  });

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
                  pressOptions.then((_) => {});
                },
                iconSize: 32,
                icon: const Icon(Icons.apps),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  pressShutter.then((_) => {});
                },
                iconSize: 48,
                icon: const Icon(Icons.camera),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  pressSwitchCamera.then((_) => {});
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

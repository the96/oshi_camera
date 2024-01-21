import 'dart:typed_data';

import 'package:camera/camera.dart';

class Camera {
  late CameraController controller;
  Camera({required CameraDescription description}) {
    controller = CameraController(
      description,
      ResolutionPreset.max,
    );
  }

  Future<void> initialize() async {
    await controller.initialize();
  }

  Future<void> changeCamera(CameraDescription description) async {
    controller.dispose();
    controller = CameraController(
      description,
      ResolutionPreset.max,
    );
  }

  Future<Uint8List> takePicture() async {
    final pictureFile = await controller.takePicture();
    return pictureFile.readAsBytes();
  }

  bool get isInitialized => controller.value.isInitialized;
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera extends StatefulWidget {
  final List<Widget> children;
  const Camera({required this.children, Key? key}) : super(key: key);

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  late final List<CameraDescription> cameras;
  late CameraController controller;
  late Future<void> instantiate;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    instantiate = instantiateCamera();
  }

  Future<void> instantiateCamera() async {
    cameras = await availableCameras();
    controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
        future: instantiate,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(
              controller,
              child: Stack(fit: StackFit.expand, children: widget.children),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

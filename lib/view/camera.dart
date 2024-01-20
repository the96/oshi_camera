import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/provider/camera.dart';
import 'package:oshi_camera/model/camera.dart' as models;

class Camera extends ConsumerStatefulWidget {
  final List<Widget> children;
  const Camera({required this.children, Key? key}) : super(key: key);

  @override
  CameraState createState() => CameraState();
}

class CameraState extends ConsumerState<Camera> {
  // late final List<CameraDescription> cameras;
  // late CameraController controller;
  // late Future<void> instantiate;
  // int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // instantiate = instantiateCamera();
    ref.read(cameraDescriptionsProvider.notifier).load();
  }

  // Future<void> instantiateCamera() async {
  //   cameras = await availableCameras();
  //   controller = CameraController(
  //     cameras[0],
  //     ResolutionPreset.max,
  //   );
  //   await controller.initialize();
  // }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
        future: ref.watch(cameraProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              ref.watch(cameraProvider).value != null) {
            return CameraPreview(
              ref.watch(cameraProvider).value!.controller,
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

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/provider/camera.dart';

class Camera extends ConsumerStatefulWidget {
  final List<Widget> children;
  const Camera({required this.children, Key? key}) : super(key: key);

  @override
  CameraState createState() => CameraState();
}

class CameraState extends ConsumerState<Camera> {
  @override
  void initState() {
    super.initState();

    ref.read(cameraDescriptionsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
        future: ref.watch(cameraProvider.future),
        builder: (context, snapshot) {
          final camera = ref.watch(cameraProvider).value;

          if (snapshot.connectionState == ConnectionState.done &&
              camera != null &&
              camera.isInitialized) {
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

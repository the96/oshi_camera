import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/camera.dart';
import 'package:oshi_camera/provider/camera_overlay.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:oshi_camera/view/component/presentational/overlay_image.dart';

class Camera extends ConsumerStatefulWidget {
  const Camera({Key? key}) : super(key: key);

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
          final overlayImages = ref.watch(overlayImagesProvider);

          if (snapshot.connectionState == ConnectionState.done &&
              camera != null &&
              camera.isInitialized) {
            return CameraPreview(
              ref.watch(cameraProvider).value!.controller,
              child: Stack(fit: StackFit.expand, children: [
                for (final image in overlayImages) OverlayImage(image: image),
                const OverlayRouter(),
              ]),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

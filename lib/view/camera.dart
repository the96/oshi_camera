import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/camera.dart';
import 'package:oshi_camera/provider/overlay_images.dart';

class Camera extends ConsumerStatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  CameraState createState() => CameraState();
}

class CameraState extends ConsumerState<Camera> {
  Offset? offset;
  double? scale;

  @override
  void initState() {
    super.initState();

    ref.read(cameraDescriptionsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
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
                for (final overlayImage in overlayImages)
                  Positioned(
                    left: overlayImage.x,
                    top: overlayImage.y,
                    width: overlayImage.width * overlayImage.scale,
                    height: overlayImage.height * overlayImage.scale,
                    child: GestureDetector(
                      onLongPress: () {
                        offset = Offset(
                          overlayImage.x,
                          overlayImage.y,
                        );
                        scale = overlayImage.scale;
                      },
                      onLongPressMoveUpdate: (details) {
                        overlayImage.x =
                            offset!.dx + details.offsetFromOrigin.dx;
                        overlayImage.y =
                            offset!.dy + details.offsetFromOrigin.dy;
                        ref.read(overlayImagesProvider.notifier).update();
                      },
                      onScaleStart: (details) {
                        scale = overlayImage.scale;
                      },
                      onScaleUpdate: (details) {
                        overlayImage.scale = scale! * details.scale;
                        ref.read(overlayImagesProvider.notifier).update();
                      },
                      child: Image.memory(overlayImage.image),
                    ),
                  ),
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

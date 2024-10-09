import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/camera.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:oshi_camera/provider/overlay_router.dart';
import 'package:oshi_camera/provider/view_size.dart';

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

  void onScaleStart(ScaleStartDetails details, OverlayImage overlayImage) {
    scale = overlayImage.scale;
    offset = Offset(
      overlayImage.x,
      overlayImage.y,
    );
    scale = overlayImage.scale;
  }

  void onScaleUpdate(ScaleUpdateDetails details, OverlayImage overlayImage) {
    if (details.pointerCount == 1) {
      overlayImage.x += details.focalPointDelta.dx;
      overlayImage.y += details.focalPointDelta.dy;
    } else if (details.pointerCount == 2) {
      final prevWidth = overlayImage.width * overlayImage.scale;
      final prevHeight = overlayImage.height * overlayImage.scale;

      overlayImage.scale = scale! * details.scale;
      final width = overlayImage.width * overlayImage.scale;
      final height = overlayImage.height * overlayImage.scale;
      overlayImage.x -= (width - prevWidth) / 2;
      overlayImage.y -= (height - prevHeight) / 2;
    }
    ref.read(overlayImagesProvider.notifier).update();
  }

  Widget buildOverlayImageWidget(OverlayImage overlayImage, bool isCameraView) {
    return Positioned(
      left: overlayImage.x,
      top: overlayImage.y,
      width: overlayImage.width * overlayImage.scale,
      height: overlayImage.height * overlayImage.scale,
      child: isCameraView
          ? GestureDetector(
              onScaleStart: (details) => onScaleStart(details, overlayImage),
              onScaleUpdate: (details) => onScaleUpdate(details, overlayImage),
              child: Image.memory(overlayImage.image),
            )
          : Image.memory(overlayImage.image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCameraView = ref.watch(overlayRouterProvider).top?.isCameraView ?? false;
    final overlayImages = ref.watch(overlayImagesProvider);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FutureBuilder<void>(
        future: ref.watch(cameraProvider.future),
        builder: (context, snapshot) {
          final camera = ref.watch(cameraProvider).value;

          if (snapshot.connectionState == ConnectionState.done && camera != null && camera.isInitialized) {
            final overlayImageWidgets = overlayImages
                .map(
                  (overlayImage) => buildOverlayImageWidget(overlayImage, isCameraView),
                )
                .toList();

            final width = MediaQuery.of(context).size.width;
            final ratio = camera.controller.value.aspectRatio;
            final height = width * ratio;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(viewSizeProvider.notifier).state = Size(width, height);
            });

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: width,
                  height: height,
                  child: AspectRatio(
                    aspectRatio: ratio,
                    child: CameraPreview(
                      ref.watch(cameraProvider).value!.controller,
                      child: Stack(
                        fit: StackFit.expand,
                        children: overlayImageWidgets,
                      ),
                    ),
                  ),
                ),
                const OverlayRouter(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

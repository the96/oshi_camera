import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/controller/camera.dart';
import 'package:oshi_camera/model/overlay_controller.dart';
import 'package:oshi_camera/model/import_processing_image.dart';
import 'package:oshi_camera/provider/camera.dart';
import 'package:oshi_camera/provider/overlay_router.dart';
import 'package:oshi_camera/view/component/app_controller.dart';
import 'package:oshi_camera/view/component/camera_controller.dart';
import 'package:oshi_camera/view/component/image_trim_dialog.dart';

class OverlayRouter extends ConsumerWidget {
  const OverlayRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stack = ref.watch(overlayRouterProvider);
    final topState = stack.top;
    if (topState == null) {
      return defaultWidget();
    }
    final topWidget = stack.top!.widget;
    return topWidget;
  }

  static Widget defaultWidget() {
    return CameraController(
      pressOptions: (WidgetRef ref) => push(routeName: appRoute, ref: ref),
      pressShutter: takePicture,
      pressSwitchCamera: switchCamera,
    );
  }

  static Widget routing(
    String routeName, [
    Map<String, Object> args = const {},
  ]) {
    switch (routeName) {
      case appRoute:
        return const AppController();
      case imageTrimDialogRoute:
        return ImageTrimDialog(image: args['image'] as ImportProcessingImage);
      case '/':
        return defaultWidget();
      default:
        throw Exception('cannot routing default');
    }
  }

  static void push({
    required String routeName,
    required WidgetRef ref,
    Map<String, Object> args = const {},
  }) {
    final stack = ref.read(overlayRouterProvider);
    final current = stack.top;

    final pushed = stack.push(
      CameraOverlayController(
        routeName: routeName,
        widget: routing(routeName, args),
      ),
    );
    ref.read(overlayRouterProvider.notifier).state = pushed;

    if (current?.isCameraView != pushed.top?.isCameraView) {
      ref.read(cameraProvider).value!.controller.pausePreview().then((_) {});
    }
  }

  static void pop(WidgetRef ref) {
    final stack = ref.read(overlayRouterProvider);
    final current = stack.top;
    final popped = stack.pop();

    if (current?.isCameraView != popped.top?.isCameraView) {
      ref.read(cameraProvider).value!.controller.resumePreview().then((_) {});
    }

    ref.read(overlayRouterProvider.notifier).state = popped;
  }
}

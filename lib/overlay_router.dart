import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:oshi_camera/controller/camera.dart';
import 'package:oshi_camera/model/overlay_controller.dart';
import 'package:oshi_camera/provider/camera.dart';
import 'package:oshi_camera/provider/overlay_router.dart';
import 'package:oshi_camera/view/component/app_controller/app_controller.dart';
import 'package:oshi_camera/view/component/app_controller/delete_confirm_dialog.dart';
import 'package:oshi_camera/view/component/camera_controller.dart';
import 'package:oshi_camera/view/component/image_import_dialog/image_transparentize_dialog.dart';
import 'package:oshi_camera/view/component/image_import_dialog/image_trim_dialog.dart';
import 'package:oshi_camera/view/component/overlay_image_controller/overlay_image_controller.dart';
import 'package:oshi_camera/view/component/processed_image_viewer/processed_image_viewer.dart';

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
      case overlayImageControllerRoute:
        return const OverlayImageController();
      case deleteConfirmDialogRoute:
        return const DeleteConfirmDialog();
      case imageTrimDialogRoute:
        return ImageTrimDialog(image: args['image'] as img.Image);
      case imageTransparentizeDialogRoute:
        return const ImageTransparentizeDialog();
      case processedImageViewerRoute:
        return const ProcessedImageViewer();
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

    pushed.printStack();

    ref.read(overlayRouterProvider.notifier).state = pushed;

    if (current?.isCameraView != pushed.top?.isCameraView) {
      ref.read(cameraProvider).value!.controller.pausePreview().then((_) {});
    }
  }

  static void replace({
    required String routeName,
    required WidgetRef ref,
    Map<String, Object> args = const {},
  }) {
    final stack = ref.read(overlayRouterProvider);
    final current = stack.top;

    final replaced = stack.replace(
      CameraOverlayController(
        routeName: routeName,
        widget: routing(routeName, args),
      ),
    );

    replaced.printStack();

    ref.read(overlayRouterProvider.notifier).state = replaced;

    if (current?.isCameraView != replaced.top?.isCameraView) {
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

    popped.printStack();

    ref.read(overlayRouterProvider.notifier).state = popped;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/controller/camera.dart';
import 'package:oshi_camera/model/overlay_controller.dart';
import 'package:oshi_camera/model/import_processing_image.dart';
import 'package:oshi_camera/provider/overlay_router.dart';
import 'package:oshi_camera/view/component/app_controller.dart';
import 'package:oshi_camera/view/component/camera_controller.dart';
import 'package:oshi_camera/view/component/image_import_dialog.dart';
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
      pressOptions: (WidgetRef ref) => push(routeName: '/apps', ref: ref),
      pressShutter: takePicture,
      pressSwitchCamera: switchCamera,
    );
  }

  static Widget routing(
    String routeName, [
    Map<String, Object> args = const {},
  ]) {
    switch (routeName) {
      case '/apps':
        return const AppController();
      case '/image/edit':
        return ImageTrimDialog(image: args['image'] as ImportProcessingImage);
      case '/':
      default:
        return defaultWidget();
    }
  }

  static void push({
    required String routeName,
    required WidgetRef ref,
    Map<String, Object> args = const {},
  }) {
    final pushed = ref.read(overlayRouterProvider).push(
          CameraOverlayController(
            routeName: routeName,
            widget: routing(routeName, args),
          ),
        );
    ref.read(overlayRouterProvider.notifier).state = pushed;
  }

  static void pop(WidgetRef ref) {
    final popped = ref.read(overlayRouterProvider).pop();
    ref.read(overlayRouterProvider.notifier).state = popped;
  }
}

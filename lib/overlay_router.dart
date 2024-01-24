import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/controller/camera.dart';
import 'package:oshi_camera/model/overlay_state.dart';
import 'package:oshi_camera/provider/overlay_state.dart';
import 'package:oshi_camera/view/component/app.dart';
import 'package:oshi_camera/view/component/camera_controller.dart';

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

  static Widget routing(String routeName) {
    switch (routeName) {
      case '/apps':
        return App();
      case '/':
      default:
        return defaultWidget();
    }
  }

  static void push({
    required String routeName,
    required WidgetRef ref,
  }) {
    final pushed = ref.read(overlayRouterProvider).push(
          CameraOverlayState(
            routeName: routeName,
            widget: routing(routeName),
          ),
        );
    ref.read(overlayRouterProvider.notifier).state = pushed;
  }

  static void pop(WidgetRef ref) {
    final popped = ref.read(overlayRouterProvider).pop();
    ref.read(overlayRouterProvider.notifier).state = popped;
  }
}

import 'package:flutter/material.dart';

class CameraOverlayController {
  final String routeName;
  final Widget widget;
  final Map<String, Object> args;

  CameraOverlayController({
    required this.routeName,
    required this.widget,
    this.args = const {},
  });
}

class CameraOverlayControllerStack {
  final List<CameraOverlayController> stack;
  CameraOverlayControllerStack(this.stack);

  CameraOverlayControllerStack push(CameraOverlayController state) {
    stack.add(state);
    return CameraOverlayControllerStack(stack);
  }

  CameraOverlayControllerStack pop() {
    stack.removeLast();
    return CameraOverlayControllerStack(stack);
  }

  CameraOverlayController? get top => stack.lastOrNull;

  bool get isEmpty => stack.isEmpty;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraOverlayState {
  final String routeName;
  final Widget widget;

  CameraOverlayState({required this.routeName, required this.widget});
}

class CameraOverlayStateStack {
  final List<CameraOverlayState> stack;
  CameraOverlayStateStack(this.stack);

  CameraOverlayStateStack push(CameraOverlayState state) {
    stack.add(state);
    return CameraOverlayStateStack(stack);
  }

  CameraOverlayStateStack pop() {
    stack.removeLast();
    return CameraOverlayStateStack(stack);
  }

  CameraOverlayState? get top => stack.lastOrNull;

  bool get isEmpty => stack.isEmpty;
}

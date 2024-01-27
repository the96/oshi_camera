import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_controller.dart';

final overlayRouterProvider =
    StateProvider<CameraOverlayControllerStack>((ref) {
  return CameraOverlayControllerStack([]);
});

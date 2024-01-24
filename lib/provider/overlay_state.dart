import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_state.dart';

final overlayRouterProvider = StateProvider<CameraOverlayStateStack>((ref) {
  return CameraOverlayStateStack([]);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_controller.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/view/component/camera_controller.dart';

final overlayRouterProvider =
    StateProvider<CameraOverlayControllerStack>((ref) {
  return CameraOverlayControllerStack([
    CameraOverlayController(
      routeName: rootRoute,
      widget: OverlayRouter.defaultWidget(),
    ),
  ]);
});

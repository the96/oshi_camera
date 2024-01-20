import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/camera.dart';

class CameraDescriptionsNotifier
    extends StateNotifier<List<CameraDescription>> {
  CameraDescriptionsNotifier(this.ref) : super([]);
  final Ref ref;

  Future<void> load() async {
    state = await availableCameras();
  }
}

final cameraDescriptionsProvider =
    StateNotifierProvider<CameraDescriptionsNotifier, List<CameraDescription>>(
        (ref) {
  return CameraDescriptionsNotifier(ref);
});

final cameraIndexProvider = StateProvider<int>((_) => 0);

final cameraProvider = FutureProvider<Camera?>((ref) async {
  final cameraDescriptions = ref.watch(cameraDescriptionsProvider);
  int cameraIndex = ref.watch(cameraIndexProvider);

  if (cameraDescriptions.isEmpty) {
    return null;
  }

  if (cameraDescriptions.length <= cameraIndex) {
    if (kDebugMode) {
      throw Exception("Camera is not found.");
    }

    cameraIndex = 0;
    ref.read(cameraIndexProvider.notifier).state = cameraIndex;
  }

  final camera = Camera(description: cameraDescriptions[cameraIndex]);
  await camera.initialize();
  return camera;
});

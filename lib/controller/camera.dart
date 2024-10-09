import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:oshi_camera/provider/camera.dart';

Future<img.Image?> takePictureToImage(WidgetRef ref) async {
  final camera = ref.watch(cameraProvider).value;
  if (camera == null) {
    return null;
  }

  final picture = await camera.takePicture();
  final image = img.decodeImage(picture)!;
  return image;
}

Future<void> takePicture(WidgetRef ref) async {
  final camera = ref.watch(cameraProvider).value;
  if (camera == null) {
    return Future<void>.value();
  }

  final picture = await camera.takePicture();
  final datestr = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
  ImageGallerySaver.saveImage(picture, name: datestr);
  return;
}

Future<void> switchCamera(WidgetRef ref) async {
  final length = ref.read(cameraDescriptionsProvider).length;
  final index = ref.read(cameraIndexProvider);
  ref.read(cameraIndexProvider.notifier).state = (index + 1) % length;
}

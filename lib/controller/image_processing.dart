import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oshi_camera/model/overlay_controller.dart';
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:oshi_camera/provider/overlay_router.dart';

Future<bool> pickImage(WidgetRef ref) async {
  final imageFile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 100,
  );
  final bytes = await imageFile?.readAsBytes();
  if (bytes == null) {
    return false;
  }

  final image = decodeImage(bytes);
  if (image != null) {
    // final images = ref.read(overlayImagesProvider);
    // ref.read(overlayImagesProvider.notifier).state = [
    //   ...images,
    //   OverlayImage(
    //     image: image,
    //   ),
    // ];
    OverlayRouter.push(
      ref: ref,
      routeName: '/image/edit',
      args: {
        'image': OverlayImage(
          image: image,
        ),
      },
    );
  }
  return image != null;
}

// 画像を選択して表示する関数
// Future<void> pickAndShowImage(WidgetRef ref) async {
//   final image = await pickImage();
//   if (image == null) {
//     return;
//   }
//   final overlay = ref.read(cameraOverlayProvider);

//   final fixedImage = Image(
//     width: image.width,
//     height: image.height,
//     numChannels: 4,
//   );
//   final isBack =
//       (r, g, b) => r < 70 && g > 205 && b < 70 || r < 5 && g < 5 && b < 5;
//   for (var pixel in image) {
//     final x = pixel.x;
//     final y = pixel.y;
//     final r = pixel.r;
//     final g = pixel.g;
//     final b = pixel.b;
//     final a = isBack(r, g, b) ? 0 : 255;
//     fixedImage.setPixelRgba(x, y, r, g, b, a);
//   }

//   final png = encodePng(fixedImage);
//   ref.read(cameraOverlayProvider.notifier).state = [
//     ...overlay,
//     material.Positioned(
//       top: 0,
//       left: 0,
//       bottom: 0,
//       right: 0,
//       child: material.Image.memory(
//         png,
//         fit: material.BoxFit.contain,
//       ),
//     ),
//   ];
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';

Future<bool> pickImage(WidgetRef ref) async {
  final imageFile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 100,
  );
  final bytes = await imageFile?.readAsBytes();
  if (bytes == null) {
    return false;
  }

  final image = decodeImage(bytes)?.convert(numChannels: 4);
  if (image != null) {
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

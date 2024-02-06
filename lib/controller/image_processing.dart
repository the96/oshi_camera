import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oshi_camera/model/import_processing_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/view/component/image_trim_dialog.dart';

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
      routeName: imageTrimDialogRoute,
      args: {
        'image': ImportProcessingImage(
          image: image,
        ),
      },
    );
  }
  return image != null;
}

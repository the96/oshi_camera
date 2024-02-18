import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';

Future<Image> pickImage(WidgetRef ref) async {
  final imageFile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 100,
  );
  final bytes = await imageFile?.readAsBytes();
  if (bytes == null) {
    throw Exception('image file is null');
  }

  final image = decodeImage(bytes)?.convert(numChannels: 4);
  if (image == null) {
    throw Exception('image is null');
  }
  return image;
}

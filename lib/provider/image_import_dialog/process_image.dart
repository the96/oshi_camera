import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:oshi_camera/model/image_import_dialog/chroma_setting.dart';
import 'package:oshi_camera/model/image_import_dialog/crop_setting.dart';
import 'package:oshi_camera/model/import_processing_image.dart';

final cropSettingProvider = StateProvider<CropSetting?>((ref) => null);
final chromaSettingProvider = StateProvider<ChromaSetting?>((ref) => null);
final originalImageProvider = StateProvider<img.Image?>((ref) => null);

final trimmedImageProvider = Provider<img.Image?>((ref) {
  final original = ref.watch(originalImageProvider);
  if (original == null) return null;

  final crop = ref.watch(cropSettingProvider);
  if (crop == null) return null;

  return img.copyCrop(
    original,
    x: crop.x,
    y: crop.y,
    width: crop.width,
    height: crop.height,
  );
});

final trimmedImageUint8ListProvider = Provider<Uint8List?>((ref) {
  final trimmedImage = ref.watch(trimmedImageProvider);
  if (trimmedImage == null) return null;

  return img.encodePng(trimmedImage);
});

final processedImageProvider = FutureProvider<img.Image?>((ref) {
  final original = ref.watch(trimmedImageProvider);
  if (original == null) return Future.value(null);

  final chroma = ref.watch(chromaSettingProvider);
  if (chroma == null) return Future.value(original);

  final processed = ImageProcessor.process(original, chroma);
  return Future.value(processed);
});

final processedImageUint8ListProvider = FutureProvider<Uint8List?>((ref) async {
  final processedImage = await ref.watch(processedImageProvider.future);
  if (processedImage == null) return null;

  return img.encodePng(processedImage);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:oshi_camera/provider/overlay_router.dart';

class ImageImportDialog extends ConsumerWidget {
  final OverlayImage image;
  const ImageImportDialog({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(fit: StackFit.expand, children: [
      Container(color: Theme.of(context).dialogBackgroundColor),
      Center(child: Image.memory(image.bytes, fit: BoxFit.contain)),
      Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(bottom: 32),
        child: ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            image.process();
            final overlayImages = ref.read(overlayImagesProvider);
            ref.read(overlayImagesProvider.notifier).state = [
              ...overlayImages,
              image
            ];
            OverlayRouter.pop(ref);
          },
        ),
      ),
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/db/processed_image.dart';
import 'package:oshi_camera/main.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';

const processedImageViewerRoute = '/processed/image/viewer';

class ProcessedImageViewer extends ConsumerStatefulWidget {
  const ProcessedImageViewer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProcessedImageViewerState();
}

class _ProcessedImageViewerState extends ConsumerState<ProcessedImageViewer> {
  List<ProcessedImage> processedImages = [];

  @override
  void initState() {
    super.initState();

    ProcessedImageProvider.all(handler.db).then(
      (value) => setState(() => processedImages = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnails = processedImages
        .map(
          (e) => Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 187, 187, 187),
              border: Border.all(color: Colors.black),
            ),
            child: GestureDetector(
              onTap: () {
                final images = ref.read(overlayImagesProvider);

                final added = [
                  ...images,
                  e.bytes,
                ];
                ref.read(overlayImagesProvider.notifier).state = added;
                OverlayRouter.pop(ref);
              },
              child: Image.memory(e.bytes, fit: BoxFit.contain),
            ),
          ),
        )
        .toList();

    final gridView = GridView.count(crossAxisCount: 3, children: thumbnails);
    return Center(
      child: Container(
        color: Colors.white,
        child: gridView,
      ),
    );
  }
}

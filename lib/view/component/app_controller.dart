import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/controller/image_processing.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';

const appRoute = '/apps';

class AppController extends ConsumerStatefulWidget {
  const AppController({super.key});

  @override
  ConsumerState<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends ConsumerState<AppController> {
  bool enableChooseImageButton = true;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      height: 64,
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        color: Colors.black45.withOpacity(0.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => OverlayRouter.pop(ref),
              iconSize: 32,
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
            ),
            IconButton(
              onPressed: enableChooseImageButton ? () => pickImage(ref) : null,
              iconSize: 32,
              icon: const Icon(Icons.photo_outlined),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                ref.read(overlayImagesProvider.notifier).state = [];
              },
              iconSize: 32,
              icon: const Icon(Icons.layers_clear_outlined),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {},
              iconSize: 32,
              icon: const Icon(Icons.apps),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

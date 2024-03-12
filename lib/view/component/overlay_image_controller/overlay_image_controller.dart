import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';

const overlayImageControllerRoute = '/apps/overlay';

class OverlayImageController extends ConsumerStatefulWidget {
  const OverlayImageController({super.key});

  @override
  ConsumerState<OverlayImageController> createState() => _OverlayImageControllerState();
}

class _OverlayImageControllerState extends ConsumerState<OverlayImageController> {
  OverlayImage? selected;

  @override
  Widget build(BuildContext context) {
    final overlayImages = ref.watch(overlayImagesProvider);

    final overlayImageButtons = overlayImages.reversed.map((overlayImage) {
      return ElevatedButton(
        onPressed: () {
          setState(() => selected = overlayImage);
        },
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            visualDensity: VisualDensity.compact),
        child: Container(
          alignment: Alignment.center,
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected == overlayImage ? Colors.red : Colors.transparent,
              width: 2,
            ),
          ),
          child: Image.memory(
            overlayImage.image,
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
        ),
      );
    }).toList();

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        color: Colors.black45.withOpacity(0.2),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  iconSize: 32,
                  color: Colors.white,
                  onPressed: () => OverlayRouter.pop(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_left_outlined),
                  iconSize: 32,
                  color: Colors.white,
                  onPressed: () {
                    if (selected == null) return;
                    final index = overlayImages.indexOf(selected!);
                    if (index == overlayImages.length - 1) return;
                    ref.read(overlayImagesProvider.notifier).up(index);
                  },
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: overlayImageButtons,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right_outlined),
                  iconSize: 32,
                  color: Colors.white,
                  onPressed: () {
                    if (selected == null) return;
                    final index = overlayImages.indexOf(selected!);
                    if (index == 0) return;
                    ref.read(overlayImagesProvider.notifier).down(index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 32,
                  color: Colors.white,
                  onPressed: () {
                    if (selected == null) return;
                    ref.read(overlayImagesProvider.notifier).remove(selected!);
                    setState(() => selected = null);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/image_import_dialog/chroma_setting.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/image_import_dialog/process_image.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:oshi_camera/view/component/image_import_dialog/image_import_render.dart';
import 'package:throttling/throttling.dart';

const imageTransparentizeDialogRoute = '/image/transparentize';

class ImageTransparentizeDialog extends ConsumerStatefulWidget {
  const ImageTransparentizeDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ImageTransparentizeDialogState();
}

class _ImageTransparentizeDialogState
    extends ConsumerState<ImageTransparentizeDialog> {
  int x = 0;
  int y = 0;

  @override
  Widget build(BuildContext context) {
    final asyncProcessedImage = ref.watch(processedImageProvider);
    final asyncProcessedBytes = ref.watch(processedImageUint8ListProvider);

    final processedImage = asyncProcessedImage.value;
    final processedBytes = asyncProcessedBytes.value;

    final loaded = !asyncProcessedImage.isLoading &&
        !asyncProcessedBytes.isLoading &&
        asyncProcessedImage.hasValue &&
        asyncProcessedBytes.hasValue;
    final cropSetting = ref.watch(cropSettingProvider);
    final ratio =
        cropSetting != null ? cropSetting.width / cropSetting.height : 0.0;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                loaded
                    ? ImportImageRender(
                        image: processedImage!,
                        bytes: processedBytes!,
                        pointer: Offset(x.toDouble(), y.toDouble()),
                        onImageTap: (color, dx, dy) {
                          final setting = ref.read(chromaSettingProvider);
                          ref.read(chromaSettingProvider.notifier).state =
                              ChromaSetting(
                            r: color.red,
                            g: color.green,
                            b: color.blue,
                            strength: setting?.strength ?? 0,
                          );
                          x = dx;
                          y = dy;
                        },
                      )
                    : AspectRatio(
                        aspectRatio: ratio,
                        child: Container(
                          color: Colors.white,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  child: Text(
                    '背景色の閾値',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(bottom: 32),
                    transformAlignment: Alignment.bottomCenter,
                    height: 32,
                    child: ImageImportSlider(updated: (v) {
                      final setting = ref.read(chromaSettingProvider);
                      ref.read(chromaSettingProvider.notifier).state =
                          ChromaSetting(
                        r: setting?.r ?? 0,
                        g: setting?.g ?? 0,
                        b: setting?.b ?? 0,
                        strength: v,
                      );
                    }),
                  ),
                ),
                ElevatedButton(
                  child: const Text('確定'),
                  onPressed: () {
                    final images = ref.read(overlayImagesProvider);
                    final added = [
                      ...images,
                      processedBytes!,
                    ];
                    ref.read(overlayImagesProvider.notifier).state = added;
                    OverlayRouter.pop(ref);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImageImportSlider extends ConsumerStatefulWidget {
  final Function updated;
  const ImageImportSlider({super.key, required this.updated});

  @override
  ConsumerState<ImageImportSlider> createState() => _ImageImportSliderState();
}

class _ImageImportSliderState extends ConsumerState<ImageImportSlider> {
  double current = 0.0;
  double prev = 0.0;
  int updatedAt = DateTime.now().millisecondsSinceEpoch;
  Throttling throttling =
      Throttling(duration: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          iconSize: 24,
          icon: const Icon(Icons.keyboard_arrow_left),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            current = math.max(0.0, current - 0.01);
            throttling.throttle(() => widget.updated(current));
            setState(() {});
          },
        ),
        Expanded(
          child: Slider(
            value: current,
            min: 0.0,
            max: 1.0,
            onChanged: (v) async {
              prev = current;
              current = v;
              throttling.throttle(() => widget.updated(v));
              setState(() {});
            },
            onChangeEnd: (v) {
              widget.updated(v);
            },
          ),
        ),
        IconButton(
          iconSize: 24,
          icon: const Icon(Icons.keyboard_arrow_right),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            current = math.min(1.0, current + 0.01);
            throttling.throttle(() => widget.updated(current));
            setState(() {});
          },
        )
      ],
    );
  }
}

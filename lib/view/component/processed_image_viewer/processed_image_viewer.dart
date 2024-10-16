import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/controller/image_import.dart';
import 'package:oshi_camera/db/processed_image.dart';
import 'package:oshi_camera/main.dart';
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:oshi_camera/view/component/image_import_dialog/image_trim_dialog.dart';

const processedImageViewerRoute = '/processed/image/viewer';

class ProcessedImageViewer extends ConsumerStatefulWidget {
  const ProcessedImageViewer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProcessedImageViewerState();
}

enum ProcessedImageViewerMode {
  view,
  edit,
}

class _ProcessedImageViewerState extends ConsumerState<ProcessedImageViewer> {
  List<ProcessedImage> processedImages = [];
  ProcessedImageViewerMode mode = ProcessedImageViewerMode.view;

  @override
  void initState() {
    super.initState();

    ProcessedImageProvider.all(handler.db).then(
      (value) => setState(() => processedImages = value),
    );
  }

  Widget buildThumbnail(ProcessedImage e) {
    final image = Image.memory(e.bytes, fit: BoxFit.contain);

    if (mode == ProcessedImageViewerMode.view) {
      return TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          ref.read(overlayImagesProvider.notifier).add(
                OverlayImage.create(
                  x: 0,
                  y: 0,
                  width: e.width,
                  height: e.height,
                  angle: 0.0,
                  image: e.bytes,
                ),
              );
          OverlayRouter.pop(ref);
        },
        child: Center(
          child: image,
        ),
      );
    } else {
      return Stack(
        children: [
          Center(
            child: image,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await ProcessedImageProvider.delete(handler.db, e.id);
                setState(() => processedImages.remove(e));
              },
            ),
          ),
        ],
      );
    }
  }

  Widget openImportImage() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.black),
        ),
        child: const Icon(
          Icons.add,
          size: 48,
        ),
      ),
      onPressed: () {
        pickImage(ref).then(
          (value) {
            if (value == null) {
              return;
            }
            OverlayRouter.replace(
              routeName: imageTrimDialogRoute,
              ref: ref,
              args: {'image': value},
            );
          },
        );
      },
    );
  }

  Widget buildHeaderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => {
            OverlayRouter.pop(ref),
          },
        ),
        if (mode == ProcessedImageViewerMode.view)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => {
              setState(() => mode = ProcessedImageViewerMode.edit),
            },
          )
        else if (mode == ProcessedImageViewerMode.edit)
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => {
              setState(() => mode = ProcessedImageViewerMode.view),
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnails = processedImages
        .map(
          (e) => Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.black),
            ),
            child: buildThumbnail(e),
          ),
        )
        .toList();

    final thumbnailGridView = Padding(
      padding: const EdgeInsets.only(top: 52),
      child: GridView.count(crossAxisCount: 3, children: [
        openImportImage(),
        ...thumbnails,
      ]),
    );

    final buttons = Positioned(
      top: 8,
      right: 0,
      left: 0,
      child: buildHeaderButtons(),
    );

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(children: [
          thumbnailGridView,
          buttons,
        ]),
      ),
    );
  }
}

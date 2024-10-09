import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:oshi_camera/provider/view_size.dart';

Widget buildOverlayImageWidget(OverlayImage overlayImage, double scale) {
  return Positioned(
    left: overlayImage.x * scale,
    top: overlayImage.y * scale,
    width: overlayImage.width * overlayImage.scale * scale,
    height: overlayImage.height * overlayImage.scale * scale,
    child: Image.memory(overlayImage.image),
  );
}

Future<img.Image?> renderOverlayImage(WidgetRef ref, Size size) async {
  final repaintBoundary = RenderRepaintBoundary();
  final renderView = RenderView(
    // ignore: deprecated_member_use
    view: ui.window,
    child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: size,
      devicePixelRatio: 1.0,
    ),
  );

  final pipelineOwner = PipelineOwner();

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());

  final viewSize = ref.read(viewSizeProvider);

  double scaleWidth = size.width / viewSize.width;
  double scaleHeight = size.height / viewSize.height;
  if ((scaleWidth - scaleHeight).abs() > 0.01) {
    // ignore: avoid_print
    print('WARNING: scaleWidth: $scaleWidth, scaleHeight: $scaleHeight');
  }

  final overlayImages = ref.read(overlayImagesProvider);
  final overlayImageWidgets = overlayImages.map((image) => buildOverlayImageWidget(image, scaleWidth)).toList();

  final element = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: overlayImageWidgets,
      ),
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(element);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image widgetImage = await repaintBoundary.toImage();
  final ByteData? byteData = await widgetImage.toByteData(format: ui.ImageByteFormat.png);

  return img.decodeImage(byteData!.buffer.asUint8List());
}

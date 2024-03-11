import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/view/component/app_controller/delete_confirm_dialog.dart';
import 'package:oshi_camera/view/component/processed_image_viewer/processed_image_viewer.dart';

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
                  onPressed: () => OverlayRouter.pop(ref),
                  iconSize: 32,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    OverlayRouter.push(
                      ref: ref,
                      routeName: processedImageViewerRoute,
                    );
                  },
                  iconSize: 32,
                  icon: const Icon(Icons.image_outlined),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {},
                  iconSize: 32,
                  icon: const Icon(Icons.design_services_outlined),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    OverlayRouter.push(
                      routeName: deleteConfirmDialogRoute,
                      ref: ref,
                    );
                  },
                  iconSize: 32,
                  icon: const Icon(Icons.layers_clear_outlined),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

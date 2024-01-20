import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:oshi_camera/provider/camera.dart';
import 'package:oshi_camera/view/camera.dart';
import 'package:oshi_camera/view/component/camera_controller.dart';

void main() {
  runApp(
    const ProviderScope(
      child: OshiCamera(),
    ),
  );
}

class OshiCamera extends ConsumerWidget {
  const OshiCamera({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Oshi Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
          default:
            return MaterialPageRoute<dynamic>(
              builder: (_) => Camera(
                children: [
                  CameraController(
                    pressOptions: () {},
                    pressShutter: takePicture,
                    pressSwitchCamera: () {},
                  ),
                ],
              ),
            );
        }
      },
    );
  }

  Future<void> takePicture(WidgetRef ref) async {
    final camera = ref.watch(cameraProvider).value;
    if (camera == null) {
      return Future<void>.value();
    }

    final picture = await camera.takePicture();
    final datestr = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
    ImageGallerySaver.saveImage(picture, name: datestr);
    print("success to save image");
    await Future<void>.delayed(const Duration(seconds: 3));
    return;
  }
}

import 'package:flutter/material.dart';
import 'package:oshi_camera/view/camera.dart';
import 'package:oshi_camera/view/component/camera_controller.dart';

void main() {
  runApp(const OshiCamera());
}

class OshiCamera extends StatelessWidget {
  const OshiCamera({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oshi Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: Router.generateRoute,
    );
  }
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;
    switch (settings.name) {
      case '/':
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Camera(
            children: [
              CameraController(
                pressOptions: Future<void>.value(),
                pressShutter: Future<void>.value(),
                pressSwitchCamera: Future<void>.value(),
              ),
            ],
          ),
        );
    }
  }
}

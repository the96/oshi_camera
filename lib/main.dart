import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/view/camera.dart';

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
      home: const Camera(),
    );
  }
}

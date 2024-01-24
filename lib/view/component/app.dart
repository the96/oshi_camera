import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/overlay_router.dart';

class App extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onPressed: () {},
              iconSize: 32,
              icon: const Icon(Icons.photo_outlined),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {},
              iconSize: 32,
              icon: const Icon(Icons.apps),
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

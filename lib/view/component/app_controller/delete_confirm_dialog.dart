import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';

const deleteConfirmDialogRoute = '/app/delete_confirm_dialog';

class DeleteConfirmDialog extends ConsumerWidget {
  const DeleteConfirmDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      content: const Text('画面上に配置した画像を削除してもよろしいですか？'),
      contentPadding: const EdgeInsets.all(16),
      actionsPadding: const EdgeInsets.all(4),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            OverlayRouter.pop(ref);
          },
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            ref.read(overlayImagesProvider.notifier).clear();
            OverlayRouter.pop(ref);
          },
          child: const Text('削除'),
        ),
      ],
    );
  }
}

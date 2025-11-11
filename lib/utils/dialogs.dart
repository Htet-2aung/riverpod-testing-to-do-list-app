import 'package:flutter/cupertino.dart';

void showCupertinoErrorDialog(BuildContext context, String msg) {
  showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
          title: const Text('Error'), content: Text(msg), actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))]));
}

void showCupertinoConfirmationDialog(BuildContext context,
    {required String title, required String content, required VoidCallback onConfirm}) {
  showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
              CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm')),
            ],
          ));
}
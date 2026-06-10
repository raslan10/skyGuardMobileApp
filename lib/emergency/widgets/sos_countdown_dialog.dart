import 'dart:async';

import 'package:flutter/material.dart';

class SosCountdownDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SosCountdownDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<SosCountdownDialog> {
  int secondsLeft = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft == 1) {
        timer.cancel();
        widget.onConfirm();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Emergency SOS'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Emergency report will be sent automatically.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '$secondsLeft seconds remaining',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            timer?.cancel();
            widget.onCancel();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            timer?.cancel();
            widget.onConfirm();
          },
          child: const Text('Send Now'),
        ),
      ],
    );
  }
}
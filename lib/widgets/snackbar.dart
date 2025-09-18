import 'dart:async';
import 'package:flutter/material.dart';

void showAppSnackBar(BuildContext context, String message,
    {bool success = false, Color? backgroundColor, Duration? duration,}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor ??
        (success
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: duration ?? const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void showCountdownSnackBar(
  BuildContext context,
  String message, {
  int seconds = 5,
  bool success = true,
  Color? backgroundColor,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  int current = seconds;
  Timer? timer;

  final Color bg = backgroundColor ??
      (success
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.error);

  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 56 + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setState) {
              timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
                if (current <= 1) {
                  timer?.cancel();
                  entry.remove();
                } else {
                  setState(() => current--);
                }
              });

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: current / seconds,
                            end: (current - 1) / seconds,
                          ),
                          duration: const Duration(milliseconds: 900),
                          builder: (context, value, child) {
                            return SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 3,
                                backgroundColor: bg.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white,),
                              ),
                            );
                          },
                        ),
                        Text(
                          '$current',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
}

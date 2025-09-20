import 'package:flutter/material.dart';

class RemoveConfirmDialog extends StatelessWidget {
  final String title;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const RemoveConfirmDialog({
    super.key,
    required this.title,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 400,
          height: 200,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 28, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600, height: 1.6),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onConfirm,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: Colors.black),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: FilledButton(
                      onPressed: onCancel,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: Text(cancelText, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: -8,
          top: -8,
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.close, size: 18, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../configs/context.dart';

class CapsuleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const CapsuleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? theme.buttonTheme.colorScheme?.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1000),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        elevation: 0
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? theme.buttonTheme.colorScheme?.onPrimary,
          fontSize: buttonFontSize,
        ),
      ),
    );
  }
}

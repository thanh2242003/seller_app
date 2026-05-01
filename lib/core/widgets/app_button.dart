import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.data,
    required this.onTap,
    this.borderColor = const Color(0xCCCAC8C8),
    this.backgroundColor = Colors.white,
    this.iconPath,
    this.textColor = Colors.black,
    this.enabled = true,
    this.textStyle,
  });

  final String data;
  final void Function() onTap;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final String? iconPath;
  final bool enabled;
  final TextStyle? textStyle;


  @override
  Widget build(BuildContext context) {
    // Nếu disable thì đổi màu
    final Color effectiveBg = enabled ? backgroundColor : Colors.grey.shade800;
    final Color effectiveText = enabled ? textColor : Colors.grey.shade400;
    final Color effectiveBorder = enabled ? borderColor : Colors.grey.shade600;

    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBg,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: effectiveBorder, width: 2),
        ),
      ),
      child: iconPath != null
          ? Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(iconPath!, width: 24, height: 24),
          const SizedBox(width: 40),
          Text(
            data,
            style: TextStyle(
              color: effectiveText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      )
          : Text(
        data,
        style: textStyle
      ),
    );
  }
}

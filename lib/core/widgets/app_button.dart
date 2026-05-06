import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.label,
    this.data,
    this.onPressed,
    this.onTap,
    this.borderColor = const Color(0xCCCAC8C8),
    this.backgroundColor = Colors.white,
    this.iconPath,
    this.textColor = Colors.black,
    this.enabled = true,
    this.textStyle,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
  });

  final String? label;
  final String? data;
  final VoidCallback? onPressed;
  final void Function()? onTap;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final String? iconPath;
  final bool enabled;
  final TextStyle? textStyle;
  final AppButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final String buttonText = label ?? data ?? 'Button';
    final VoidCallback? callback = onPressed ?? onTap;

    // Nếu disable thì đổi màu
    final Color effectiveBg = enabled && !isLoading
        ? backgroundColor
        : Colors.grey.shade800;
    final Color effectiveText = enabled && !isLoading
        ? textColor
        : Colors.grey.shade400;
    final Color effectiveBorder = enabled && !isLoading
        ? borderColor
        : Colors.grey.shade600;

    if (variant == AppButtonVariant.outlined) {
      return OutlinedButton(
        onPressed: (enabled && !isLoading) ? callback : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: effectiveBorder, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                buttonText,
                style: textStyle ?? TextStyle(color: effectiveText),
              ),
      );
    }

    return ElevatedButton(
      onPressed: (enabled && !isLoading) ? callback : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBg,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: effectiveBorder, width: 2),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : iconPath != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(iconPath!, width: 24, height: 24),
                const SizedBox(width: 40),
                Text(
                  buttonText,
                  style: TextStyle(
                    color: effectiveText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            )
          : Text(
              buttonText,
              style: textStyle ?? TextStyle(color: effectiveText),
            ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? titleWidget;
  final Widget? action;
  final Color? backgroundColor;
  final bool showBack;
  final double? height;
  final TextStyle? titleStyle;

  const BasicAppbar({
    this.titleText,
    this.titleWidget,
    this.showBack = true,
    this.action,
    this.backgroundColor,
    this.height,
    this.titleStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Determine title widget
    Widget titleDisplay;
    if (titleWidget != null) {
      titleDisplay = titleWidget!;
    } else if (titleText != null) {
      titleDisplay = Text(
        titleText!,
        style: titleStyle ?? AppTextStyle.h3.copyWith(color: Colors.black87),
      );
    } else {
      titleDisplay = const SizedBox.shrink();
    }

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.lightBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      toolbarHeight: height ?? 56,
      title: titleDisplay,
      titleSpacing: 0,
      actions: [
        if (action != null)
          Padding(padding: const EdgeInsets.only(right: 16.0), child: action!),
      ],
      leading: showBack
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: AppColors.secondColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 15,
                  color: Colors.black,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);
}

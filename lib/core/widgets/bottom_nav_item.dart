import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_pill.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Catalog health',
            subtitle: 'Keep listing quality and stock in sync',
            child: Column(
              children: const [
                _ProductRow(
                  name: 'Summer Overshirt',
                  detail: '24 variants · 18 colors',
                  stock: '58 in stock',
                  status: 'Live',
                  color: Colors.green,
                ),
                SizedBox(height: 12),
                _ProductRow(
                  name: 'Classic Hoodie',
                  detail: '12 variants · 4 sizes',
                  stock: '14 in stock',
                  status: 'Low stock',
                  color: Colors.orange,
                ),
                SizedBox(height: 12),
                _ProductRow(
                  name: 'Minimal Tote',
                  detail: '8 variants · 2 materials',
                  stock: 'Published',
                  status: 'Draft',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Quick actions',
            child: Column(
              children: const [
                _QuickAction(
                  label: 'Add new product',
                  icon: Icons.add_box_rounded,
                ),
                SizedBox(height: 10),
                _QuickAction(
                  label: 'Publish hidden items',
                  icon: Icons.publish_rounded,
                ),
                SizedBox(height: 10),
                _QuickAction(
                  label: 'Review pricing rules',
                  icon: Icons.sell_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.name,
    required this.detail,
    required this.stock,
    required this.status,
    required this.color,
  });

  final String name;
  final String detail;
  final String stock;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.inventory_2_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyle.buttonLarge),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stock,
                  style: AppTextStyle.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(label: status, color: color),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyle.buttonLarge)),
        const Icon(Icons.chevron_right_rounded),
      ],
    );
  }
}

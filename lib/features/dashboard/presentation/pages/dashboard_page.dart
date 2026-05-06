import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/app_session.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _reload(BuildContext context) async {
    await context.read<DashboardCubit>().reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) {
        final repository = DashboardRepositoryImpl();
        return DashboardCubit(
          getDashboardUseCase: GetDashboardUseCase(repository),
        )..load();
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final colorScheme = Theme.of(context).colorScheme;
          final metrics = state.metrics;

          if (state.isLoading && metrics == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null && metrics == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dashboard')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _reload(context),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (metrics == null) {
            return const Scaffold(body: SizedBox.shrink());
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: [
                IconButton(
                  onPressed: () => _reload(context),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => _reload(context),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.16),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${AppSession.instance.shopName}',
                          style: AppTextStyle.h2,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your shop is connected to the live dashboard API.',
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            StatusPill(
                              label: 'Orders: ${metrics.totalOrders}',
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 10),
                            StatusPill(
                              label: 'Products: ${metrics.totalProducts}',
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.92,
                    children: [
                      _MetricTile(
                        label: 'Total revenue',
                        value: AppNumberFormat.format(metrics.totalRevenue),
                        helper: 'All-time shop revenue',
                        icon: Icons.payments_rounded,
                        color: Colors.green,
                      ),
                      _MetricTile(
                        label: 'Total orders',
                        value: metrics.totalOrders.toString(),
                        helper:
                            '${metrics.ordersByStatus['pending']?.count ?? 0} pending',
                        icon: Icons.receipt_long_rounded,
                        color: Colors.blue,
                      ),
                      _MetricTile(
                        label: 'Total products',
                        value: metrics.totalProducts.toString(),
                        helper: '${metrics.totalCustomers} customers',
                        icon: Icons.inventory_2_rounded,
                        color: Colors.deepOrange,
                      ),
                      _MetricTile(
                        label: 'Low stock',
                        value: metrics.lowStockInventory.length.toString(),
                        helper: 'Need restock now',
                        icon: Icons.warning_rounded,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Orders by status',
                    subtitle: 'From the shop dashboard endpoint',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: metrics.ordersByStatus.entries
                          .map(
                            (entry) => StatusPill(
                              label:
                                  '${entry.key}: ${entry.value.count} | ${AppNumberFormat.format(entry.value.revenue)}',
                              color: colorScheme.primary,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Top selling products',
                    subtitle: 'Last dashboard snapshot',
                    child: Column(
                      children: metrics.topSellingProducts
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProductRow(
                                title: item.title,
                                subtitle: '${item.totalSold} sold',
                                trailing: AppNumberFormat.format(
                                  item.totalRevenue,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (metrics.lowStockInventory.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Low stock products',
                      subtitle: 'Items that need attention',
                      child: Column(
                        children: metrics.lowStockInventory
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ProductRow(
                                  title: item.title,
                                  subtitle: 'Current stock',
                                  trailing: item.currentStock.toString(),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.16), colorScheme.surface],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 18),
          Text(value, style: AppTextStyle.h2),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyle.bodyMedium),
          const SizedBox(height: 4),
          Text(
            helper,
            style: AppTextStyle.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.star_rounded, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.buttonLarge),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          trailing,
          style: AppTextStyle.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

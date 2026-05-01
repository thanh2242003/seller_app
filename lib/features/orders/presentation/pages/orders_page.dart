import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_models.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const List<String> _filters = <String>[
    'all',
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  Future<void> _reload(BuildContext context) {
    return context.read<OrdersCubit>().reload();
  }

  void _selectStatus(BuildContext context, String status) {
    context.read<OrdersCubit>().changeStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrdersCubit>(
      create: (_) {
        final repository = OrdersRepositoryImpl();
        return OrdersCubit(getOrdersUseCase: GetOrdersUseCase(repository))
          ..load();
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          final result = state.result;

          if (state.isLoading && result == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null && result == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Orders')),
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

          if (result == null) {
            return const Scaffold(body: SizedBox.shrink());
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Orders'),
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
                  SectionCard(
                    title: 'Order pipeline',
                    subtitle: 'Filter by status from the API',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filters
                          .map(
                            (status) => ChoiceChip(
                              label: Text(status),
                              selected: state.selectedStatus == status,
                              onSelected: (_) => _selectStatus(context, status),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Orders',
                    subtitle: '${result.pagination.total} total orders',
                    child: Column(
                      children: result.orders
                          .map(
                            (order) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OrderCard(
                                order: order,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          OrderDetailPage(orderId: order.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Pagination',
                    child: Row(
                      children: [
                        Text(
                          'Page ${result.pagination.page}/${result.pagination.pages}',
                        ),
                        const Spacer(),
                        Text('Limit ${result.pagination.limit}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderSummaryModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('#${order.id}', style: AppTextStyle.h3),
                const Spacer(),
                StatusPill(
                  label: order.status,
                  color: _statusColor(order.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.shippingAddress, style: AppTextStyle.buttonLarge),
            const SizedBox(height: 4),
            Text(
              '${order.items.length} item(s) · ${AppNumberFormat.format(order.totalAmount)}',
              style: AppTextStyle.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

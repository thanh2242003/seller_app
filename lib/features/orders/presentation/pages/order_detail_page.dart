import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_models.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../cubit/order_detail_cubit.dart';
import '../cubit/order_detail_state.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Future<void> _reload(BuildContext context) {
    return context.read<OrderDetailCubit>().reload();
  }

  Future<void> _updateStatus(BuildContext context, String status) {
    return context.read<OrderDetailCubit>().updateStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderDetailCubit>(
      create: (_) {
        final repository = OrdersRepositoryImpl();
        return OrderDetailCubit(
          orderId: widget.orderId,
          getOrderDetailUseCase: GetOrderDetailUseCase(repository),
          updateOrderStatusUseCase: UpdateOrderStatusUseCase(repository),
        )..load();
      },
      child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) {
          final order = state.detail;

          if (state.isLoading && order == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null && order == null) {
            return Scaffold(
              appBar: AppBar(title: Text('Order Detail')),
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

          if (order == null) {
            return const Scaffold(body: SizedBox.shrink());
          }

          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(title: Text('Order Detail')),
            body: RefreshIndicator(
              onRefresh: () => _reload(context),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(order.id, style: AppTextStyle.h3),
                            const Spacer(),
                            StatusPill(
                              label: order.status,
                              color: _statusColor(order.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.customer.name.isEmpty
                              ? 'Customer info not available'
                              : order.customer.name,
                          style: AppTextStyle.bodyLarge.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Shipping',
                    child: Text('Address: ${order.address}'),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Customer',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${order.receiverName.isNotEmpty ? order.receiverName : order.customer.name}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Phone: ${order.receiverPhone.isNotEmpty ? order.receiverPhone : order.customer.phone}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Items',
                    child: Column(
                      children: order.items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ItemRow(item: item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Status actions',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _allowedTransitions(order.status)
                          .map(
                            (status) => FilledButton.tonal(
                              onPressed: state.isUpdating
                                  ? null
                                  : () => _updateStatus(context, status),
                              child: Text(status),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
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

  List<String> _allowedTransitions(String status) {
    switch (status) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['processing', 'cancelled'];
      case 'processing':
        return ['shipped', 'cancelled'];
      case 'shipped':
        return ['delivered', 'cancelled'];
      default:
        return <String>[];
    }
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderDetailItemModel item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.inventory_2_rounded, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.title, style: AppTextStyle.buttonLarge),
              const SizedBox(height: 4),
              Text('Qty: ${item.quantity}'),
              if (item.color.isNotEmpty || item.size.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Color: ${item.color}  Size: ${item.size}'),
              ],
            ],
          ),
        ),
        Text(AppNumberFormat.format(item.product.price)),
      ],
    );
  }
}

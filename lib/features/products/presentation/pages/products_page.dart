import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../data/models/product_models.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/product_usecases.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import 'create_product_page.dart';
import 'product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  Future<void> _reload(BuildContext context) async {
    await context.read<ProductsCubit>().reload();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsCubit>(
      create: (_) {
        final repository = ProductRepositoryImpl();
        return ProductsCubit(
          getDraftProductsUseCase: GetDraftProductsUseCase(repository),
          getPublishedProductsUseCase: GetPublishedProductsUseCase(repository),
          getDeletedProductsUseCase: GetDeletedProductsUseCase(repository),
        )..load();
      },
      child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          final currentResult = state.currentResult;

          if (state.isLoading && currentResult == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null && currentResult == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Products')),
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

          return Scaffold(
            appBar: AppBar(
              title: const Text('Products'),
              actions: [
                IconButton(
                  onPressed: () => _reload(context),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateProductPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
            body: RefreshIndicator(
              onRefresh: () => _reload(context),
              child: Column(
                children: [
                  // Tab buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Published',
                          isSelected: state.currentTab == ProductTab.published,
                          onTap: () {
                            context.read<ProductsCubit>().selectTab(
                              ProductTab.published,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _TabButton(
                          label: 'Drafts',
                          isSelected: state.currentTab == ProductTab.drafts,
                          onTap: () {
                            context.read<ProductsCubit>().selectTab(
                              ProductTab.drafts,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _TabButton(
                          label: 'Deleted',
                          isSelected: state.currentTab == ProductTab.deleted,
                          onTap: () {
                            context.read<ProductsCubit>().selectTab(
                              ProductTab.deleted,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Products list
                  if (currentResult == null)
                    const Expanded(child: Center(child: SizedBox.shrink()))
                  else if (currentResult.products.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inventory_2_rounded, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'No products in this category',
                              style: AppTextStyle.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentResult.products.length,
                        itemBuilder: (context, index) {
                          final product = currentResult.products[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ProductDetailPage(
                                      productId: product.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.32),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.labelMedium.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final ProductSummaryModel product;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: AppTextStyle.h3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Variants: ${product.variantCount}',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (product.isPublished)
                      StatusPill(label: 'Published', color: Colors.green)
                    else if (product.isDraft)
                      StatusPill(label: 'Draft', color: Colors.orange)
                    else if (product.isDeleted)
                      StatusPill(label: 'Deleted', color: Colors.red),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        AppNumberFormat.format(product.price),
                        style: AppTextStyle.labelMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discounted',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        AppNumberFormat.format(product.discountedPrice),
                        style: AppTextStyle.labelMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sold',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${product.salesNumber} units',
                        style: AppTextStyle.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

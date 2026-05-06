import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../data/models/product_models.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/product_usecases.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _discountedPriceCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _discountedPriceCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _discountedPriceCtrl.dispose();
    super.dispose();
  }

  void _loadProductToForm(ProductDetailModel product) {
    _titleCtrl.text = product.title;
    _descriptionCtrl.text = product.description;
    _priceCtrl.text = product.price.toString();
    _discountedPriceCtrl.text = product.discountedPrice.toString();
  }

  void _showActionMenu(BuildContext context, ProductDetailModel product) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _ProductActionMenu(
        product: product,
        onPublish: () {
          Navigator.pop(ctx);
          context.read<ProductDetailCubit>().publishProduct(product.id);
        },
        onUnpublish: () {
          Navigator.pop(ctx);
          context.read<ProductDetailCubit>().unpublishProduct(product.id);
        },
        onSoftDelete: () {
          Navigator.pop(ctx);
          context.read<ProductDetailCubit>().softDeleteProduct(product.id);
        },
        onRestore: () {
          Navigator.pop(ctx);
          context.read<ProductDetailCubit>().restoreProduct(product.id);
        },
        onDelete: () {
          Navigator.pop(ctx);
          _showDeleteDialog(context, product);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductDetailModel product) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductDetailCubit>().permanentlyDeleteProduct(
                product.id,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailCubit>(
      create: (_) {
        final repository = ProductRepositoryImpl();
        return ProductDetailCubit(
          getProductDetailUseCase: GetProductDetailUseCase(repository),
          updateProductUseCase: UpdateProductUseCase(repository),
          publishProductUseCase: PublishProductUseCase(repository),
          unpublishProductUseCase: UnpublishProductUseCase(repository),
          softDeleteProductUseCase: SoftDeleteProductUseCase(repository),
          restoreProductUseCase: RestoreProductUseCase(repository),
          deleteProductUseCase: DeleteProductUseCase(repository),
          permanentlyDeleteProductUseCase: PermanentlyDeleteProductUseCase(
            repository,
          ),
        )..load(widget.productId);
      },
      child: BlocListener<ProductDetailCubit, ProductDetailState>(
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operation completed successfully')),
            );
            if (state.product == null) {
              Navigator.pop(context);
            }
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            final product = state.product;

            if (state.isLoading && product == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (product == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Product Detail')),
                body: const Center(child: Text('Product not found')),
              );
            }

            if (_titleCtrl.text.isEmpty) {
              _loadProductToForm(product);
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Product Detail'),
                actions: [
                  IconButton(
                    onPressed: () => _showActionMenu(context, product),
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.32),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatusInfo(
                                label: 'Status',
                                value: product.isPublished
                                    ? 'Published'
                                    : product.isDraft
                                    ? 'Draft'
                                    : 'Deleted',
                              ),
                              _StatusInfo(
                                label: 'Sold',
                                value: '${product.salesNumber} units',
                              ),
                              _StatusInfo(
                                label: 'Rating',
                                value:
                                    '${product.ratings.toStringAsFixed(1)} ⭐',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Basic Information', style: AppTextStyle.h2),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _discountedPriceCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Discounted',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Save Changes',
                          onPressed: state.isSaving
                              ? null
                              : () {
                                  final updates = <String, dynamic>{
                                    'title': _titleCtrl.text,
                                    'description': _descriptionCtrl.text,
                                    'price': int.tryParse(_priceCtrl.text) ?? 0,
                                    'discountedPrice':
                                        int.tryParse(
                                          _discountedPriceCtrl.text,
                                        ) ??
                                        0,
                                  };
                                  context
                                      .read<ProductDetailCubit>()
                                      .updateProduct(product.id, updates);
                                },
                          isLoading: state.isSaving,
                        ),
                        const SizedBox(height: 16),
                        SectionCard(
                          title: 'Variants',
                          subtitle: '${product.variants.length} variants',
                          child: product.variants.isEmpty
                              ? Center(
                                  child: Text(
                                    'No variants',
                                    style: AppTextStyle.bodyMedium,
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: product.variants.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (_, idx) {
                                    final variant = product.variants[idx];
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${variant.color} - ${variant.size}',
                                                  style:
                                                      AppTextStyle.labelMedium,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Stock: ${variant.stock}',
                                                  style: AppTextStyle.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 16),
                        SectionCard(
                          title: 'Colors',
                          subtitle: '${product.colors.length} colors',
                          child: product.colors.isEmpty
                              ? Center(
                                  child: Text(
                                    'No colors',
                                    style: AppTextStyle.bodyMedium,
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: product.colors
                                      .map(
                                        (color) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(color.title),
                                        ),
                                      )
                                      .toList(),
                                ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  if (state.isSaving)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusInfo extends StatelessWidget {
  const _StatusInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyle.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyle.labelMedium),
      ],
    );
  }
}

class _ProductActionMenu extends StatelessWidget {
  const _ProductActionMenu({
    required this.product,
    required this.onPublish,
    required this.onUnpublish,
    required this.onSoftDelete,
    required this.onRestore,
    required this.onDelete,
  });

  final ProductDetailModel product;
  final VoidCallback onPublish;
  final VoidCallback onUnpublish;
  final VoidCallback onSoftDelete;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.isDraft)
              _ActionButton(
                label: 'Publish',
                icon: Icons.publish_rounded,
                onTap: onPublish,
              ),
            if (product.isPublished)
              _ActionButton(
                label: 'Unpublish',
                icon: Icons.unpublished_rounded,
                onTap: onUnpublish,
              ),
            if (!product.isDeleted)
              _ActionButton(
                label: 'Soft Delete',
                icon: Icons.delete_rounded,
                onTap: onSoftDelete,
              ),
            if (product.isDeleted)
              _ActionButton(
                label: 'Restore',
                icon: Icons.restore_rounded,
                onTap: onRestore,
              ),
            if (product.isDeleted)
              _ActionButton(
                label: 'Permanent Delete',
                icon: Icons.delete_forever_rounded,
                color: Colors.red,
                onTap: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/product_models.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/usecases/product_usecases.dart';
import '../cubit/create_product_cubit.dart';
import '../cubit/product_state.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _discountedPriceCtrl;
  late final TextEditingController _categoryIdCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _sizesCtrl;

  final List<ProductColorModel> _colors = [];
  final List<ProductVariantModel> _variants = [];
  final List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _priceCtrl = TextEditingController();
    _discountedPriceCtrl = TextEditingController();
    _categoryIdCtrl = TextEditingController();
    _genderCtrl = TextEditingController();
    _sizesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _discountedPriceCtrl.dispose();
    _categoryIdCtrl.dispose();
    _genderCtrl.dispose();
    _sizesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }

    final selectedPaths = result.files
        .map((file) => file.path)
        .whereType<String>()
        .toList();

    if (selectedPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không lấy được đường dẫn ảnh từ trình chọn file'),
        ),
      );
      return;
    }

    final merged = [..._imagePaths, ...selectedPaths];
    if (merged.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được chọn tối đa 5 ảnh')),
      );
      return;
    }

    setState(() {
      _imagePaths
        ..clear()
        ..addAll(merged);
    });
  }

  void _addColor() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AddColorDialog(
        onSave: (color) {
          setState(() => _colors.add(color));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _addVariant() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AddVariantDialog(
        colors: _colors.map((e) => e.title).toList(),
        sizes: _sizesCtrl.text.split(',').map((e) => e.trim()).toList(),
        onSave: (variant) {
          setState(() => _variants.add(variant));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    final sizes = _sizesCtrl.text.split(',').map((e) => e.trim()).toList();

    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    context.read<CreateProductCubit>().createProduct(
      title: _titleCtrl.text,
      description: _descriptionCtrl.text,
      price: int.tryParse(_priceCtrl.text) ?? 0,
      discountedPrice: int.tryParse(_discountedPriceCtrl.text) ?? 0,
      categoryId: _categoryIdCtrl.text,
      gender: int.tryParse(_genderCtrl.text) ?? 0,
      imagePaths: _imagePaths,
      sizes: sizes,
      colors: _colors,
      variants: _variants,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateProductCubit>(
      create: (_) {
        final repository = ProductRepositoryImpl();
        return CreateProductCubit(
          createProductUseCase: CreateProductUseCase(repository),
        );
      },
      child: BlocListener<CreateProductCubit, ProductDetailState>(
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product created successfully')),
            );
            Navigator.pop(context);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: BlocBuilder<CreateProductCubit, ProductDetailState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: const Text('Create Product')),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Basic Information', style: AppTextStyle.h2),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _titleCtrl,
                          hint: 'e.g., Áo Polo Nam Xanh Đen',
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _descriptionCtrl,
                          hint: 'Product description',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _priceCtrl,
                          hint: 'e.g.,250000',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _discountedPriceCtrl,
                          hint: 'e.g.,199000',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Text('Category & Gender', style: AppTextStyle.h2),
                        const SizedBox(height: 16),
                        BlocBuilder<CreateProductCubit, ProductDetailState>(
                          builder: (context, state) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _categoryIdCtrl.text.isEmpty
                                    ? null
                                    : _categoryIdCtrl.text,
                                hint: const Text('Select Category'),
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: state.categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Text(category.name),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(
                                      () => _categoryIdCtrl.text = newValue,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _genderCtrl,
                          hint: '0 for Unisex, 1 for Male, 2 for Female',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Text('Images & Sizes', style: AppTextStyle.h2),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _imagePaths.isEmpty
                                          ? 'No images selected'
                                          : 'Selected ${_imagePaths.length}/5 images',
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _pickImages,
                                    icon: const Icon(Icons.image_outlined),
                                    label: const Text('Choose Images'),
                                  ),
                                ],
                              ),
                              if (_imagePaths.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(_imagePaths.length, (
                                    index,
                                  ) {
                                    final path = _imagePaths[index];
                                    final fileName = path
                                        .split(RegExp(r'[\\/]'))
                                        .last;
                                    return InputChip(
                                      label: Text(fileName),
                                      onDeleted: () {
                                        setState(() {
                                          _imagePaths.removeAt(index);
                                        });
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _sizesCtrl,
                          hint: 'S, M, L, XL, XXL',
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Colors (${_colors.length})',
                          style: AppTextStyle.h2,
                        ),
                        const SizedBox(height: 12),
                        if (_colors.isEmpty)
                          Text(
                            'No colors added yet',
                            style: AppTextStyle.bodyMedium,
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _colors.length,
                            itemBuilder: (ctx, idx) {
                              final color = _colors[idx];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            color.rgb[0],
                                            color.rgb[1],
                                            color.rgb[2],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(color.title)),
                                      IconButton(
                                        onPressed: () {
                                          setState(() => _colors.removeAt(idx));
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Add Color',
                          onPressed: _addColor,
                          variant: AppButtonVariant.outlined,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Variants (${_variants.length})',
                          style: AppTextStyle.h2,
                        ),
                        const SizedBox(height: 12),
                        if (_variants.isEmpty)
                          Text(
                            'No variants added yet',
                            style: AppTextStyle.bodyMedium,
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _variants.length,
                            itemBuilder: (ctx, idx) {
                              final variant = _variants[idx];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
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
                                              style: AppTextStyle.labelMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Stock: ${variant.stock}',
                                              style: AppTextStyle.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(
                                            () => _variants.removeAt(idx),
                                          );
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Add Variant',
                          onPressed: _addVariant,
                          variant: AppButtonVariant.outlined,
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
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: 'Create Product',
                  onPressed: () => _submitForm(context),
                  isLoading: state.isSaving,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============ Add Color Dialog ============

class _AddColorDialog extends StatefulWidget {
  const _AddColorDialog({required this.onSave});

  final Function(ProductColorModel) onSave;

  @override
  State<_AddColorDialog> createState() => _AddColorDialogState();
}

class _AddColorDialogState extends State<_AddColorDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _rCtrl;
  late TextEditingController _gCtrl;
  late TextEditingController _bCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _rCtrl = TextEditingController(text: '0');
    _gCtrl = TextEditingController(text: '0');
    _bCtrl = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rCtrl.dispose();
    _gCtrl.dispose();
    _bCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(controller: _titleCtrl, hint: 'e.g., Xanh, Đen'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _rCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: _gCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: _bCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final color = ProductColorModel(
              title: _titleCtrl.text,
              rgb: [
                int.tryParse(_rCtrl.text) ?? 0,
                int.tryParse(_gCtrl.text) ?? 0,
                int.tryParse(_bCtrl.text) ?? 0,
              ],
            );
            widget.onSave(color);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ============ Add Variant Dialog ============

class _AddVariantDialog extends StatefulWidget {
  const _AddVariantDialog({
    required this.colors,
    required this.sizes,
    required this.onSave,
  });

  final List<String> colors;
  final List<String> sizes;
  final Function(ProductVariantModel) onSave;

  @override
  State<_AddVariantDialog> createState() => _AddVariantDialogState();
}

class _AddVariantDialogState extends State<_AddVariantDialog> {
  late TextEditingController _stockCtrl;
  String? _selectedColor;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _stockCtrl = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Variant'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedColor,
            decoration: const InputDecoration(labelText: 'Color'),
            items: widget.colors.isEmpty
                ? [const DropdownMenuItem(value: '', child: Text('No colors'))]
                : widget.colors
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            onChanged: (v) => setState(() => _selectedColor = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedSize,
            decoration: const InputDecoration(labelText: 'Size'),
            items: widget.sizes.isEmpty
                ? [const DropdownMenuItem(value: '', child: Text('No sizes'))]
                : widget.sizes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            onChanged: (v) => setState(() => _selectedSize = v),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _stockCtrl,
            hint: '10',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_selectedColor == null || _selectedSize == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select color and size')),
              );
              return;
            }
            final variant = ProductVariantModel(
              color: _selectedColor!,
              size: _selectedSize!,
              stock: int.tryParse(_stockCtrl.text) ?? 0,
            );
            widget.onSave(variant);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

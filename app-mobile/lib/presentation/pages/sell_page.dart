import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/errors/api_exception.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/listings_repository.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _repository = ListingsRepository();
  final _storage = AuthStorageService();
  final _picker = ImagePicker();

  final List<XFile> _images = [];
  bool _isSubmitting = false;
  String _category = 'Mode';

  static const _categories = ['Mode', 'Beauté', 'Tech', 'Maison'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1600);
    if (picked.isEmpty) return;
    setState(() {
      _images
        ..clear()
        ..addAll(picked.take(6));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final tokens = await _storage.getTokens();
    if (tokens == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour publier une annonce.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final photoUrls = <String>[];
      for (final image in _images) {
        final uploadedUrl = await _repository.uploadListingImage(
          tokens.accessToken,
          File(image.path),
        );
        photoUrls.add(uploadedUrl);
      }

      await _repository.createListing(
        tokens.accessToken,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _category,
        photoUrls: photoUrls,
        condition: 'good',
        parcelSize: 'M',
        isNegotiable: true,
      );

      if (!mounted) return;
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() {
        _images.clear();
        _category = 'Mode';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce publiée.')),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.userMessage
          : 'Impossible de publier pour le moment.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Créer une annonce', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoute un titre, un prix et quelques photos. On garde ça simple.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _SellCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Photos', style: AppTextStyles.h3),
                            const SizedBox(height: 8),
                            Text(
                              'Ajoute jusqu’à 6 photos lumineuses.',
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.zero,
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: _images.isEmpty
                                    ? Column(
                                        children: [
                                          Container(
                                            width: 54,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceLight,
                                              borderRadius: BorderRadius.zero,
                                            ),
                                            child: Icon(
                                              PhosphorIcons.cameraPlus(),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Ajouter des photos',
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        height: 94,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _images.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 10),
                                          itemBuilder: (context, index) => ClipRRect(
                                            borderRadius: BorderRadius.zero,
                                            child: Image.file(
                                              File(_images[index].path),
                                              width: 94,
                                              height: 94,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SellCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Infos produit', style: AppTextStyles.h3),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                hintText: 'Titre de l’annonce',
                              ),
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? 'Ajoute un titre'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Décris ton article',
                              ),
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? 'Ajoute une description'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Prix en FCFA',
                              ),
                              validator: (value) => value == null || value.trim().isEmpty
                                  ? 'Ajoute un prix'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _categories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final value = _categories[index];
                                  final selected = value == _category;
                                  return GestureDetector(
                                    onTap: () => setState(() => _category = value),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.inputBackground,
                                        borderRadius: BorderRadius.zero,
                                        border: Border.all(color: AppColors.cardBorder),
                                      ),
                                      child: Text(
                                        value,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Publier mon annonce'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellCard extends StatelessWidget {
  final Widget child;

  const _SellCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

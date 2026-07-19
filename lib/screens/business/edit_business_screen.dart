import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/business_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class EditBusinessScreen extends ConsumerStatefulWidget {
  const EditBusinessScreen({super.key});

  @override
  ConsumerState<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends ConsumerState<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final business = ref.read(businessProvider).currentBusiness;
    if (business != null) {
      _nameController.text = business.name;
      _categoryController.text = business.category ?? '';
      _cityController.text = business.city ?? '';
      _phoneController.text = business.phone ?? '';
      _addressController.text = business.address ?? '';
      _websiteController.text = business.website ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final business = ref.read(businessProvider).currentBusiness;
      if (business == null) return;

      final apiService = ref.read(apiServiceProvider);
      await apiService.patch(
        '/businesses/${business.id}',
        data: {
          'name': _nameController.text.trim(),
          'category': _categoryController.text.trim(),
          'city': _cityController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'website': _websiteController.text.trim(),
        },
      );

      await ref.read(businessProvider.notifier).fetchBusinesses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update business')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Business Name',
                hint: 'Enter business name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Category',
                hint: 'e.g. Restaurant, Salon, Clinic',
                controller: _categoryController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'City',
                hint: 'Enter city',
                controller: _cityController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone',
                hint: 'Enter phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Address',
                hint: 'Enter full address',
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Website',
                hint: 'https://...',
                controller: _websiteController,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Save Changes',
                isLoading: _isSaving,
                width: double.infinity,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

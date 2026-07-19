import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../models/customer_model.dart';
import '../../providers/business_provider.dart';
import '../../providers/customers_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customersProvider.notifier).fetchCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerModel> _filterCustomers(List<CustomerModel> customers) {
    if (_searchQuery.isEmpty) return customers;
    final query = _searchQuery.toLowerCase();
    return customers.where((c) {
      return c.displayName.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersProvider);
    final hasBusiness = ref.watch(businessProvider).currentBusiness != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      floatingActionButton: hasBusiness
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCustomerDialog(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: Icon(Icons.person_add, color: Theme.of(context).colorScheme.onPrimary),
              label: Text('Add Customer',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            )
          : null,
      body: !hasBusiness
          ? const EmptyWidget(
              message: 'Please set up your business first',
              icon: Icons.business_outlined,
            )
          : state.isLoading
              ? const LoadingWidget()
              : state.error != null
                  ? AppErrorWidget(
                      message: state.error!,
                      onRetry: () {
                        ref.read(customersProvider.notifier).fetchCustomers();
                      },
                    )
                  : state.customers.isEmpty
                      ? const EmptyWidget(
                          message:
                              'No customers yet. Add your first customer to start building your CRM.',
                          icon: Icons.people_outline,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(customersProvider.notifier)
                                .fetchCustomers();
                          },
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildStats(context, state),
                              const SizedBox(height: 16),
                              _buildSearchBar(context),
                              const SizedBox(height: 16),
                              ..._filterCustomers(state.customers).map(
                                (c) => _CustomerCard(customer: c),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name or phone...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
    );
  }

  Widget _buildStats(BuildContext context, CustomersState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.people, color: Theme.of(context).colorScheme.primary, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    state.totalCustomers.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Total Customers',
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: Theme.of(context).dividerColor),
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.cake_outlined,
                      color: AppColors.orange, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    state.upcomingBirthdays.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Upcoming Birthdays',
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddCustomerSheet(),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          child: Text(
            customer.displayName.isNotEmpty
                ? customer.displayName[0].toUpperCase()
                : 'C',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          customer.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.phone,
              style: const TextStyle(fontSize: 13),
            ),
            if (customer.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: customer.tags
                    .take(3)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.chevron_right,
            color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
    );
  }
}

class _AddCustomerSheet extends ConsumerStatefulWidget {
  const _AddCustomerSheet();

  @override
  ConsumerState<_AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends ConsumerState<_AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Customer',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Phone (required)',
                    hint: 'Enter customer phone number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Name',
                    hint: 'Enter customer name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    hint: 'Enter customer email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Notes',
                    hint: 'Any notes about this customer',
                    controller: _notesController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Tags (comma-separated)',
                    hint: 'e.g. VIP, Regular, New',
                    controller: _tagsController,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Add Customer',
                    isLoading: _isSaving,
                    width: double.infinity,
                    onPressed: _saveCustomer,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final tags = _tagsController.text.trim().isNotEmpty
        ? _tagsController.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList()
        : null;

    final success = await ref.read(customersProvider.notifier).addCustomer(
          phone: _phoneController.text.trim(),
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          tags: tags,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add customer')),
        );
      }
    }
  }
}

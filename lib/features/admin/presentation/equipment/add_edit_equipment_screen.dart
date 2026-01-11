import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../equipment/data/equipment_repository.dart';
import '../../../equipment/domain/equipment_model.dart';

// Helper provider to fetch single equipment by ID
final equipmentByIdProvider = FutureProvider.family<Equipment?, String>((
  ref,
  id,
) {
  return ref.watch(equipmentRepositoryProvider).getEquipmentById(id);
});

class AddEditEquipmentScreen extends ConsumerStatefulWidget {
  final String? id; // If null, it's Add mode. If set, it's Edit mode.

  const AddEditEquipmentScreen({super.key, this.id});

  @override
  ConsumerState<AddEditEquipmentScreen> createState() =>
      _AddEditEquipmentScreenState();
}

class _AddEditEquipmentScreenState
    extends ConsumerState<AddEditEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();

  String _category = 'حفر'; // Default
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      // Edit Mode: Fetch data
      // We do this in a post-frame callback or use existing provider data if available
      // For simplicity, let's wait for provider in build or separate init logic.
      // Better yet, use ref.read in initState if not async, but we need async.
      // Standard pattern: use .when in build, but for form fields it's tricky.
      // Let's load once.
    }
  }

  bool _initialLoadDone = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _rentalPriceController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  void _populateForm(Equipment equipment) {
    if (_initialLoadDone) return;
    _nameController.text = equipment.name;
    _descriptionController.text = equipment.description;
    _imageUrlController.text = equipment.imageUrl;
    _rentalPriceController.text = equipment.rentalPrice.toString();
    _purchasePriceController.text = equipment.purchasePrice.toString();
    _category = equipment.category;
    _isAvailable = equipment.isAvailable;
    _initialLoadDone = true;
  }

  @override
  Widget build(BuildContext context) {
    // If edit mode, watch data
    AsyncValue<Equipment?>? equipmentAsync;
    if (widget.id != null) {
      equipmentAsync = ref.watch(equipmentByIdProvider(widget.id!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'إضافة معدة' : 'تعديل معدة'),
      ),
      body: widget.id != null && equipmentAsync != null
          ? equipmentAsync.when(
              data: (equipment) {
                if (equipment == null) {
                  return const Center(child: Text('المعدة غير موجودة'));
                }
                _populateForm(equipment);
                return _buildForm();
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('خطأ: $e')),
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المعدة'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'الوصف'),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'التصنيف'),
              items: [
                'حفر',
                'نقل',
                'بناء',
                'أخرى',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rentalPriceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر الإيجار (يومي)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _purchasePriceController,
                    decoration: const InputDecoration(labelText: 'سعر الشراء'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'رابط الصورة'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('متوفرة؟'),
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.id == null ? 'إضافة' : 'حفظ التعديلات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final equipment = Equipment(
        id: widget.id ?? '', // ID ignored in add, used in update
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
        category: _category,
        rentalPrice: double.tryParse(_rentalPriceController.text) ?? 0,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        isAvailable: _isAvailable,
        rating: 5.0, // Default for new
      );

      final repo = ref.read(equipmentRepositoryProvider);

      if (widget.id == null) {
        await repo.addEquipment(equipment);
      } else {
        await repo.updateEquipment(equipment);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

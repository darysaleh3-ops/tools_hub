import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../equipment/data/equipment_repository.dart';

class AdminEquipmentScreen extends ConsumerWidget {
  const AdminEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-use the existing filtered provider but maybe specialized one is better.
    // Ideally we want *all* equipment.
    // Let's use filteredEquipmentProvider but we need to ensure filters are clear logic-wise.
    // Actually, let's just watch the repository stream or simple future for now?
    // The `filteredEquipmentProvider` works well if we assume default filters (all).
    // Let's rely on `equipmentListProvider` which gives all.
    final equipmentAsync = ref.watch(equipmentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المعدات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/admin/equipment/add'),
          ),
        ],
      ),
      body: equipmentAsync.when(
        data: (equipmentList) {
          if (equipmentList.isEmpty) {
            return const Center(child: Text('لا توجد معدات حالياً'));
          }
          return ListView.builder(
            itemCount: equipmentList.length,
            itemBuilder: (context, index) {
              final item = equipmentList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : const Icon(Icons.construction),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.category} - ${item.rentalPrice} ر.س/يوم',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            context.go('/admin/equipment/edit/${item.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المعدة'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه المعدة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await ref.read(equipmentRepositoryProvider).deleteEquipment(id);
                // Ideally show success snackbar
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('فشل الحذف: $e')));
                }
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

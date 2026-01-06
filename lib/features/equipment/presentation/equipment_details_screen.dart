import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/equipment_model.dart';
import '../data/equipment_repository.dart';

class EquipmentDetailsScreen extends ConsumerWidget {
  final String id;
  const EquipmentDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(equipmentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المعدة')),
      body: equipmentAsync.when(
        data: (equipment) {
          final item = equipment.firstWhere(
            (e) => e.id == id,
            orElse: () => throw Exception('Item not found'),
          );
          return _buildDetails(context, item);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('حدث خطأ: $e')),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, Equipment item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(item.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.isAvailable
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.isAvailable ? 'متوفر' : 'غير متوفر',
                        style: TextStyle(
                          color: item.isAvailable
                              ? Colors.green[800]
                              : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${item.rating} (رؤية التقييمات)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      'القسم: ${item.category}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'الوصف',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Price Section
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceBox(
                        'إيجار يومي',
                        '${item.rentalPrice} ريال',
                        AppTheme.primaryColor,
                        () {
                          // Handle Rent Action
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPriceBox(
                        'شراء للمعدات',
                        '${item.purchasePrice} ريال',
                        AppTheme.secondaryColor,
                        () {
                          // Handle Buy Action
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // WhatsApp Support
                ElevatedButton.icon(
                  onPressed: () {
                    // Open WhatsApp
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('طلب مساعدة عبر الواتساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    minimumSize: const Size(double.infinity, 60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(
    String title,
    String price,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

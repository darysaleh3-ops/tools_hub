import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/domain/auth_notifier.dart';
import '../data/equipment_repository.dart';
import '../domain/equipment_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools Hub'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, ref),
            _buildCategorySection(ref),
            _buildEquipmentGrid(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?q=80&w=2070&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'أفضل المعدات لبناء أحلامك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          ref.read(searchQueryProvider.notifier).update(value),
                      decoration: const InputDecoration(
                        hintText: 'عن ماذا تبحث؟',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = [
      {'name': 'حفر', 'icon': FontAwesomeIcons.trowel},
      {'name': 'رافعات', 'icon': FontAwesomeIcons.truckRampBox},
      {'name': 'أدوات يدوية', 'icon': FontAwesomeIcons.hammer},
      {'name': 'كهرباء', 'icon': FontAwesomeIcons.bolt},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat['name'];
          return InkWell(
            onTap: () {
              final notifier = ref.read(selectedCategoryProvider.notifier);
              if (isSelected) {
                notifier.update(null);
              } else {
                notifier.update(cat['name'] as String);
              }
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    cat['icon'] as IconData,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'] as String,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : Colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEquipmentGrid(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(filteredEquipmentProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: equipmentAsync.when(
        data: (equipment) => equipment.isEmpty
            ? Center(
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('لم نجد أي نتائج للبحث الحالي'),
                    TextButton(
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).update('');
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .update(null);
                      },
                      child: const Text('مسح الفلاتر'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref
                              .read(equipmentRepositoryProvider)
                              .seedInitialData();
                          // ignore: unused_result
                          ref.refresh(equipmentListProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('فشل إضافة البيانات: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('إضافة بيانات تجريبية (للمطورين)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 400,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: equipment.length,
                itemBuilder: (context, index) {
                  return _buildEquipmentCard(context, equipment[index]);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('حدث خطأ: $e')),
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, Equipment item) {
    return GestureDetector(
      onTap: () => context.push('/equipment/${item.id}'),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 16,
                        color: index < item.rating
                            ? Colors.amber
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.rentalPrice} ريال / يوم',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.add_shopping_cart,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

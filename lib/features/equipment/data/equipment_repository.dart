import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/equipment_model.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository(FirebaseFirestore.instance);
});

final equipmentListProvider = FutureProvider<List<Equipment>>((ref) {
  return ref.watch(equipmentRepositoryProvider).getEquipment();
});

// Refactored to Notifier for Riverpod 3.x consistency
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      SelectedCategoryNotifier.new,
    );

final filteredEquipmentProvider = Provider<AsyncValue<List<Equipment>>>((ref) {
  final equipmentAsync = ref.watch(equipmentListProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return equipmentAsync.whenData((list) {
    return list.where((item) {
      final matchesQuery =
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      final matchesCategory = category == null || item.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  });
});

class EquipmentRepository {
  final FirebaseFirestore _firestore;
  EquipmentRepository(this._firestore);

  Future<List<Equipment>> getEquipment() async {
    try {
      final snapshot = await _firestore
          .collection('equipment')
          .get()
          .timeout(const Duration(seconds: 10));
      return snapshot.docs
          .map((doc) => Equipment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception(
        'فشل الاتصال بقاعدة البيانات. يرجى التأكد من إعدادات Firestore: $e',
      );
    }
  }

  Future<Equipment?> getEquipmentById(String id) async {
    final doc = await _firestore.collection('equipment').doc(id).get();
    if (doc.exists) {
      return Equipment.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}

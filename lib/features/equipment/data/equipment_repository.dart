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

  Future<void> seedInitialData() async {
    final snapshot = await _firestore.collection('equipment').get();
    if (snapshot.docs.isNotEmpty) return;

    final initialData = [
      Equipment(
        id: '',
        name: 'حفار كاتربيلر 320',
        description:
            'حفار هيدروليكي متعدد الاستخدامات، مثالي للمشاريع المتوسطة والكبيرة. يتميز بكفاءة استهلاك الوقود وقوة الحفر.',
        category: 'حفر',
        imageUrl:
            'https://755639.smushcdn.com/1335049/wp-content/uploads/2018/06/caterpillar-320-excavator.jpg?size=640x438&lossy=1&strip=1&webp=1',
        rating: 5,
        rentalPrice: 1200,
        purchasePrice: 450000,
        isAvailable: true,
      ),
      Equipment(
        id: '',
        name: 'رافعة شوكية تويوتا',
        description:
            'رافعة شوكية ديزل بقدرة رفع 3 طن. ممتازة للمستودعات والمواقع الخارجية.',
        category: 'رافعات',
        imageUrl:
            'https://liftmetrics.com/wp-content/uploads/2023/07/Toyota-Core-IC-Pneumatic-Forklift.jpg',
        rating: 4,
        rentalPrice: 350,
        purchasePrice: 85000,
        isAvailable: true,
      ),
      Equipment(
        id: '',
        name: 'مولد كهرباء 50 كيلو',
        description:
            'مولد كهرباء كاتم للصوت، مناسب للمواقع السكنية والفعاليات.',
        category: 'كهرباء',
        imageUrl: 'https://m.media-amazon.com/images/I/71w+Dq-Jm+L.jpg',
        rating: 5,
        rentalPrice: 200,
        purchasePrice: 45000,
        isAvailable: true,
      ),
      Equipment(
        id: '',
        name: 'طقم أدوات بوش الاحترافي',
        description: 'شنيور، صاروخ، ومنشار ترددي. حقيبة متكاملة للمقاولين.',
        category: 'أدوات يدوية',
        imageUrl:
            'https://m.media-amazon.com/images/I/81+5+p5+1+L._AC_SL1500_.jpg',
        rating: 4,
        rentalPrice: 50,
        purchasePrice: 2500,
        isAvailable: true,
      ),
    ];

    final batch = _firestore.batch();
    for (var item in initialData) {
      final docRef = _firestore.collection('equipment').doc();
      batch.set(docRef, item.toMap());
    }
    await batch.commit();
  }

  Future<void> addEquipment(Equipment equipment) async {
    final docRef = _firestore.collection('equipment').doc();
    final equipmentWithId = equipment.copyWith(id: docRef.id);
    await docRef.set(equipmentWithId.toMap());
  }

  Future<void> updateEquipment(Equipment equipment) async {
    await _firestore
        .collection('equipment')
        .doc(equipment.id)
        .update(equipment.toMap());
  }

  Future<void> deleteEquipment(String id) async {
    await _firestore.collection('equipment').doc(id).delete();
  }
}

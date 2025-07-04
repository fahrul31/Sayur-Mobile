import 'package:flutter/material.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:green_finance/repositories/item_repository.dart';

class ItemViewModel extends ChangeNotifier {
  final ItemRepository itemRepository;

  ItemViewModel(this.itemRepository);

  List<ItemModel> vegetables = [];
  List<ItemModel> others = [];
  bool isLoading = false;

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await itemRepository.getItems();
      vegetables = data['vegetables'] ?? [];
      others = data['others'] ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetchItems: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await itemRepository.deleteItem(id);
      await fetchItems(); // refresh list after delete
    } catch (e) {
      debugPrint("Error deleteItem: $e");
      rethrow;
    }
  }

  Future<void> createItemWithPhoto(
      String name, String type, String photoPath) async {
    try {
      await itemRepository.createItemWithPhoto(
          name: name, type: type, photoPath: photoPath);
      await fetchItems(); // Refresh data
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItemWithPhoto(
      int id, String name, String type, String photoPath) async {
    try {
      await itemRepository.updateItemWithPhoto(
        id: id,
        name: name,
        type: type,
        photoPath: photoPath,
      );
      await fetchItems();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(int id, Map<String, dynamic> fields) async {
    try {
      await itemRepository.updateItem(id, fields);
      await fetchItems();
    } catch (e) {
      rethrow;
    }
  }
}

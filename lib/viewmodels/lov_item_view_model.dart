import 'package:flutter/material.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:green_finance/repositories/lov_repository.dart';

class LovItemViewModel extends ChangeNotifier {
  final LovItemRepository lovItemRepository;

  LovItemViewModel(this.lovItemRepository);

  List<ItemModel> lovItems = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchLovItems() async {
    isLoading = true;
    notifyListeners();

    try {
      lovItems = await lovItemRepository.fetchLovItems();
      errorMessage = '';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

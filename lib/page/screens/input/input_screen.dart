import 'package:flutter/material.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:green_finance/page/components/action_handler.dart';
import 'package:green_finance/page/components/button_toggle.dart';
import 'package:green_finance/page/components/item_tile.dart';
import 'package:green_finance/page/screens/input/add_item_page.dart';
import 'package:green_finance/page/screens/input/input_detail_expense_page.dart';
import 'package:green_finance/page/screens/input/input_detail_income_page.dart';
import 'package:green_finance/repositories/route_observer.dart';
import 'package:green_finance/viewmodels/item_view_model.dart';
import 'package:provider/provider.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> with RouteAware {
  bool isPemasukanSelected = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ItemViewModel>().fetchItems();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    Future.microtask(() {
      context.read<ItemViewModel>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text("Input Data",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ItemViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Memuat data...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final kategoriSayuran = vm.vegetables;
          final kategoriLainnya = vm.others;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Button Section
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ButtonToggle(
                  isPemasukanSelected: isPemasukanSelected,
                  onToggleChanged: (bool selected) {
                    setState(() {
                      isPemasukanSelected = selected;
                    });
                  },
                ),
              ),

              // Content Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sayuran Section
                      if (kategoriSayuran.isNotEmpty) ...[
                        _buildSectionHeader("Sayuran", Icons.eco),
                        _buildGrid(kategoriSayuran),
                        const SizedBox(height: 16),
                      ],

                      // Lainnya Section
                      if (kategoriLainnya.isNotEmpty &&
                          !isPemasukanSelected) ...[
                        _buildSectionHeader("Lainnya", Icons.category),
                        _buildGrid(kategoriLainnya),
                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddItemPage.routeName);
        },
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<ItemModel> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemTile(
            item: item,
            onTap: () {
              if (isPemasukanSelected) {
                Navigator.pushNamed(
                  context,
                  InputIncomeDetailPage.routeName,
                  arguments: item.id.toString(),
                );
              } else {
                Navigator.pushNamed(context, InputExpenseDetailPage.routeName,
                    arguments: {'id': item.id.toString(), 'type': item.type});
              }
            },
            onLongPress: () {
              ActionHandler.showActions(
                context: context,
                itemId: item.id,
                itemName: item.name,
                itemPhotoUrl: item.photo,
                // onEdit: () {
                //   Navigator.pushNamed(
                //     context,
                //     AddItemPage.routeName,
                //     arguments: item,
                //   );
                // },
                onDelete: (id) => context.read<ItemViewModel>().deleteItem(id),
                onDeleted: () async {
                  await context.read<ItemViewModel>().fetchItems();
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:green_finance/page/screens/report/report_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:green_finance/page/components/button_toggle.dart';
import 'package:green_finance/viewmodels/report_view_model.dart';
import 'package:green_finance/models/report_item_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime selectedDate = DateTime.now();
  bool isIncome = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final model = context.read<ReportViewModel>();
      final dateStr = selectedDate.toIso8601String().split('T').first;
      model.fetchData(dateStr);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      final dateStr = picked.toIso8601String().split('T').first;
      context.read<ReportViewModel>().fetchData(dateStr);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          "Rekap Transaksi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today,
                  color: Colors.white, size: 22),
              tooltip: 'Pilih Tanggal',
            ),
          )
        ],
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, vm, _) {
          final vegetables = vm.reportItems['vegetables'];
          final others = vm.reportItems['others'];
          isIncome = vm.isPemasukan;

          return RefreshIndicator(
            onRefresh: () async {
              final dateStr = selectedDate.toIso8601String().split('T').first;
              vm.fetchData(dateStr);
            },
            child: Column(
              children: [
                // Header dengan tanggal dan toggle
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Info tanggal
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.date_range,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(selectedDate),
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Toggle Button
                      ButtonToggle(
                        isPemasukanSelected: isIncome,
                        onToggleChanged: (selected) {
                          isIncome = selected;
                          final dateStr =
                              selectedDate.toIso8601String().split('T').first;
                          vm.toggleTab(selected, dateStr);
                        },
                      ),
                    ],
                  ),
                ),

                if (vm.isLoading)
                  Expanded(
                    child: Center(
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50)),
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
                    ),
                  )
                else
                  Expanded(
                    child: _buildContent(vegetables, others),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      List<ReportItemModel>? vegetables, List<ReportItemModel>? others) {
    if (vegetables == null || others == null) {
      return _buildEmptyState();
    }

    if (vegetables.isEmpty && others.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vegetables.isNotEmpty) ...[
          _buildCategory("Sayuran", vegetables, Icons.eco),
          const SizedBox(height: 16),
        ],
        if (others.isNotEmpty) ...[
          _buildCategory("Lainnya", others, Icons.category),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Tidak ada data transaksi",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Belum ada transaksi pada tanggal ini",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
      String title, List<ReportItemModel> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Items list
        ...items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  final dateStr =
                      selectedDate.toIso8601String().split('T').first;
                  Navigator.pushNamed(
                    context,
                    ReportDetailPage.routeName,
                    arguments: {
                      'itemId': item.itemId.toString(),
                      'isIncome': isIncome,
                      'date': dateStr,
                    },
                  );
                },
                title: Text(
                  item.itemName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    title == "Lainnya"
                        ? "Catatan: ${item.note ?? 'Belum ada catatan'}"
                        : "${item.totalQuantityKg} kg",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Rp ${_formatPrice(item.totalPrice)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isIncome
                            ? Colors.green.shade700
                            : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

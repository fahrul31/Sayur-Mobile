import 'package:flutter/material.dart';
import 'package:green_finance/models/report_detail_model.dart';
import 'package:green_finance/viewmodels/report_detail_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReportDetailPage extends StatefulWidget {
  static const routeName = "/recap-detail";

  const ReportDetailPage({super.key});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  late String itemId;
  late bool isIncome;
  late String date;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final route = ModalRoute.of(context);
      final args = route?.settings.arguments;

      if (args == null || args is! Map<String, dynamic>) {
        debugPrint("⚠️ Argument tidak valid $args");
        return;
      }

      itemId = args['itemId'];
      isIncome = args['isIncome'];
      date = args['date'];

      final viewModel = context.read<ReportDetailViewModel>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.fetchDetail(
          isIncome: isIncome,
          itemId: itemId,
          date: date,
        );
      });

      _isInitialized = true;
    }
  }

  String formatRupiah(int amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
        .format(amount);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Detail Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ReportDetailViewModel>(
        builder: (context, model, _) {
          if (model.isLoading) {
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

          if (isIncome && model.detailIncomeData != null) {
            final data = model.detailIncomeData!;
            final details = data.details ?? [];

            return _buildDetailContent(
              itemName: data.itemName!,
              details: details,
              hargaJual: details.isNotEmpty ? details.first.pricePerKg! : 0,
              jumlahTotal:
                  details.fold<double>(0.0, (sum, e) => sum + e.quantityKg!),
              totalHarga: details.fold<int>(0, (sum, e) => sum + e.totalPrice!),
            );
          }

          if (!isIncome &&
              model.detailExpenseData != null &&
              model.detailExpenseData!.itemType == "OTHER") {
            final data = model.detailExpenseData!;
            final details = data.details ?? [];

            return _buildDetailContentOther(
              itemName: data.itemName!,
              details: details,
              totalHarga: details.fold<int>(0, (sum, e) => sum + e.totalPrice!),
            );
          }

          if (!isIncome && model.detailExpenseData != null) {
            final data = model.detailExpenseData!;
            final details = data.details ?? [];

            return _buildDetailContent(
              itemName: data.itemName!,
              details: details,
              hargaJual: details.isNotEmpty ? details.first.pricePerKg! : 0,
              jumlahTotal:
                  details.fold<double>(0.0, (sum, e) => sum + e.quantityKg!),
              totalHarga: details.fold<int>(0, (sum, e) => sum + e.totalPrice!),
            );
          }

          return _buildEmptyState();
        },
      ),
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
            "Tidak ada data detail",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContentOther({
    required String itemName,
    required List<ReportDetailModel> details,
    required int totalHarga,
  }) {
    return Column(
      children: [
        // Header Info
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isIncome ? Icons.trending_up : Icons.trending_down,
                    color:
                        isIncome ? Colors.green.shade700 : Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isIncome ? 'PEMASUKAN' : 'PENGELUARAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isIncome
                          ? Colors.green.shade700
                          : Colors.red.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                itemName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Summary Cards
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  formatRupiah(totalHarga),
                  Icons.account_balance_wallet,
                  isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Detail List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: details.length,
            itemBuilder: (context, index) {
              final detail = details[index];
              return _buildDetailCardOther(detail, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailContent({
    required String itemName,
    required List<ReportDetailModel> details,
    required int hargaJual,
    required double jumlahTotal,
    required int totalHarga,
  }) {
    return Column(
      children: [
        // Header Info
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isIncome ? Icons.trending_up : Icons.trending_down,
                    color:
                        isIncome ? Colors.green.shade700 : Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isIncome ? 'PEMASUKAN' : 'PENGELUARAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isIncome
                          ? Colors.green.shade700
                          : Colors.red.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                itemName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Summary Cards
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Berat',
                  '${jumlahTotal.toStringAsFixed(1)} kg',
                  Icons.scale,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total',
                  formatRupiah(totalHarga),
                  Icons.account_balance_wallet,
                  isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Detail List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: details.length,
            itemBuilder: (context, index) {
              final detail = details[index];
              return _buildDetailCard(detail, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCardOther(ReportDetailModel detail, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan nomor dan nama
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.note!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        if (!isIncome && detail.address != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  detail.address!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (isIncome &&
                            detail.note != null &&
                            detail.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  detail.note!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Detail transaksi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Berat',
                        '${detail.totalQuantityKg} kg',
                        Icons.scale,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Total Harga',
                        formatRupiah(detail.totalPrice!),
                        Icons.attach_money,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(ReportDetailModel detail, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan nomor dan nama
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isIncome
                              ? (detail.buyerName ?? '-')
                              : (detail.farmerName ?? '-'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        if (!isIncome && detail.address != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  detail.address!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (isIncome &&
                            detail.note != null &&
                            detail.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  detail.note!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Detail transaksi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Berat',
                        '${detail.quantityKg} kg',
                        Icons.scale,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Harga/kg',
                        formatRupiah(detail.pricePerKg!),
                        Icons.attach_money,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Total',
                        formatRupiah(detail.totalPrice!),
                        Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

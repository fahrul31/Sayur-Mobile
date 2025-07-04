import 'package:flutter/material.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:green_finance/models/report_detail_model.dart';
import 'package:green_finance/page/screens/input/input_expense_other_page.dart';
import 'package:green_finance/page/screens/input/input_expense_vegetable_page.dart';
import 'package:green_finance/repositories/route_observer.dart';
import 'package:green_finance/viewmodels/input_expense_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InputExpenseDetailPage extends StatefulWidget {
  static const String routeName = '/input-Expense-detail';
  final String id;
  final String type;

  const InputExpenseDetailPage(
      {super.key, required this.id, required this.type});

  @override
  State<InputExpenseDetailPage> createState() => _InputExpenseDetailPageState();
}

class _InputExpenseDetailPageState extends State<InputExpenseDetailPage>
    with RouteAware {
  bool _isDeleting = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final model = context.read<InputExpenseViewModel>();
      context.read<InputExpenseViewModel>().id = widget.id;
      context.read<InputExpenseViewModel>().type = widget.type;
      model.fetchExpenseReport();
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
  void didPopNext() {
    Future.microtask(() {
      final model = context.read<InputExpenseViewModel>();
      context.read<InputExpenseViewModel>().id = widget.id;
      context.read<InputExpenseViewModel>().type = widget.type;
      model.fetchExpenseReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Laporan Pengeluaran',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InputExpenseViewModel>().fetchExpenseReport();
            },
            tooltip: 'Refresh data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (widget.type == 'VEGETABLE') {
            Navigator.pushNamed(context, InputExpenseVegetablePage.routeName);
          } else {
            Navigator.pushNamed(context, InputExpenseOtherPage.routeName);
          }
        },
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<InputExpenseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading || _isDeleting) {
            return _buildLoadingState();
          }

          if (viewModel.reportItems.isEmpty) {
            return _buildEmptyState();
          }
          if (viewModel.type == 'OTHER') {
            return RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchExpenseReport();
              },
              color: const Color(0xFF4CAF50),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    _buildSummaryCardOther(viewModel),
                    const SizedBox(height: 16),

                    // Title for reports
                    Text(
                      'Daftar Catatan (${viewModel.reportItems.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Report items
                    ...viewModel.reportItems
                        .map((item) =>
                            _buildExpenseCardOther(context, item, viewModel))
                        .toList(),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchExpenseReport();
            },
            color: const Color(0xFF4CAF50),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _buildSummaryCard(viewModel),
                  const SizedBox(height: 16),

                  // Title for reports
                  Text(
                    'Daftar Catatan (${viewModel.reportItems.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Report items
                  ...viewModel.reportItems
                      .map(
                          (item) => _buildExpenseCard(context, item, viewModel))
                      .toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Memuat data laporan...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardOther(InputExpenseViewModel viewModel) {
    final totalQuantity = viewModel.reportItems
        .fold<double>(0, (sum, item) => sum + (item.totalQuantityKg ?? 0));
    final totalPrice = viewModel.reportItems
        .fold<int>(0, (sum, item) => sum + (item.totalPrice ?? 0));

    print(viewModel.reportItems[0].totalPrice);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF2E7D32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assessment, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Ringkasan Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Pengeluaran',
                  'Rp ${_formatCurrency(totalPrice)}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(InputExpenseViewModel viewModel) {
    final totalQuantity = viewModel.reportItems
        .fold<double>(0, (sum, item) => sum + (item.totalQuantityKg ?? 0));
    final totalPrice = viewModel.reportItems
        .fold<int>(0, (sum, item) => sum + (item.totalPrice ?? 0));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF2E7D32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assessment, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Ringkasan Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Kuantitas',
                  '${totalQuantity.toStringAsFixed(1)} Kg',
                  Icons.scale,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total pengeluaran',
                  'Rp ${_formatCurrency(totalPrice)}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(BuildContext context, ReportItemModel item,
      InputExpenseViewModel viewModel) {
    final dateTime = DateTime.parse(item.createdAt!);
    final formatter = DateFormat('dd MMMM yyyy');
    final date = formatter.format(dateTime.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with date and main info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.receipt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dicatat pada: $date',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(
                              '${item.totalQuantityKg ?? 0} Kg', Icons.scale),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                              'Rp ${_formatCurrency(item.totalPrice ?? 0)}',
                              Icons.attach_money),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Details expansion
                if (item.details != null && item.details!.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.visibility,
                          color: Color(0xFF4CAF50)),
                      title: Text(
                        'Detail Transaksi (${item.details!.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      children: item.details!.map((detail) {
                        return _buildDetailCard(detail);
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDeleting
                            ? null
                            : () =>
                                _showDeleteConfirmation(item.itemId, viewModel),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCardOther(BuildContext context, ReportItemModel item,
      InputExpenseViewModel viewModel) {
    final dateTime = DateTime.parse(item.createdAt!);
    final formatter = DateFormat('dd MMMM yyyy');
    final date = formatter.format(dateTime.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with date and main info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.receipt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dicatat pada: $date',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoChip(
                              'Rp ${_formatCurrency(item.totalPrice)}',
                              Icons.attach_money),
                          const SizedBox(height: 2),
                          _buildInfoChip("${item.note}", Icons.note_alt),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Details expansion
                if (item.details != null && item.details!.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.visibility,
                          color: Color(0xFF4CAF50)),
                      title: Text(
                        'Detail Transaksi (${item.details!.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      children: item.details!.map((detail) {
                        return _buildDetailCard(detail);
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isDeleting
                            ? null
                            : () =>
                                _showDeleteConfirmation(item.itemId, viewModel),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.green.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(ReportDetailModel detail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with buyer name and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person,
                            size: 16, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.farmerName ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            Text(
                              detail.phone ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            Text(
                              detail.address ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                    if (detail.note != null && detail.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.note,
                              size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              detail.note!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _showDeleteConfirmationDialog(
                    context, detail.id.toString()),
                tooltip: 'Hapus detail',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                onPressed: () => _showEditDialog(detail), //edit
                tooltip: 'Edit detail',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Transaction details in a more organized layout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                      'Kuantitas', '${detail.quantityKg} kg', Icons.scale),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildDetailItem(
                      'Harga/kg',
                      'Rp ${_formatCurrency(detail.pricePerKg ?? 0)}',
                      Icons.price_change),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildDetailItem(
                      'Total',
                      'Rp ${_formatCurrency(detail.totalPrice ?? 0)}',
                      Icons.attach_money),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //delete detail dialog
  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Hapus Catatan'),
        content:
            const Text('Apakah kamu yakin ingin menghapus detail catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog

              try {
                await context
                    .read<InputExpenseViewModel>()
                    .deleteExpenseDetailReport(id: id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Catatan berhasil dihapus'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                  await context
                      .read<InputExpenseViewModel>()
                      .fetchExpenseReport();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Gagal menghapus: $e')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada laporan pengeluaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap tombol + untuk menambah laporan pertama',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int itemId, InputExpenseViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: const Text(
            'Apakah Anda yakin ingin menghapus laporan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(itemId, viewModel);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(int id, InputExpenseViewModel viewModel) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await viewModel.deleteExpenseReport(id.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Laporan berhasil dihapus'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal menghapus: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showEditDialog(ReportDetailModel detail) {
    final formKey = GlobalKey<FormState>();
    final farmerNameController = TextEditingController(text: detail.farmerName);
    final phoneController = TextEditingController(text: detail.phone);
    final addressController = TextEditingController(text: detail.address);
    final quantityKgController =
        TextEditingController(text: detail.quantityKg.toString());
    final pricePerKgController =
        TextEditingController(text: detail.pricePerKg.toString());
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF4CAF50)),
                  SizedBox(width: 8),
                  Text(
                    'Edit Catatan Pengeluaran',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogTextField(
                        controller: farmerNameController,
                        label: 'Nama Petani',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama petani wajib diisi';
                          } else if (RegExp(r'\d').hasMatch(value)) {
                            return 'Nama petani tidak boleh mengandung angka';
                          } else if (value.trim().length > 30) {
                            return 'Nama petani maksimal 30 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: phoneController,
                        label: 'No. Telfon',
                        icon: Icons.person,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'No. telfon wajib diisi';
                          } else if (value.length < 10 || value.length > 15) {
                            return 'No. telfon tidak valid minimal 10 angka atau maksimal 15 angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: addressController,
                        label: 'Alamat',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat wajib diisi';
                          } else if (value.trim().length < 4) {
                            return 'Alamat minimal 4 karakter';
                          } else if (value.trim().length > 20) {
                            return 'Alamat maksimal 20 karakter';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: quantityKgController,
                        label: 'Kuantitas (Kg)',
                        icon: Icons.scale,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kuantitas wajib diisi';
                          } else if (value.trim().length > 6) {
                            return 'Jumlah maksimal 6 karakter';
                          } else if (value.trim() == '0' ||
                              value.trim() == '0.0') {
                            return 'Jumlah tidak boleh 0';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        controller: pricePerKgController,
                        label: 'Harga per Kg',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Harga per Kg wajib diisi';
                          }
                          if (value.trim().length < 4) {
                            return 'Harga minimal 4 karakter';
                          } else if (value.trim().length > 6) {
                            return 'Harga maksimal 6 karakter';
                          }

                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Harga harus berupa angka positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isUpdating ? null : () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: _isUpdating
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      fontStyle:
                          _isUpdating ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null // tombol disable ketika update
                      : () async {
                          setDialogState(() {
                            _isUpdating = true;
                          });

                          if (!formKey.currentState!.validate()) {
                            setDialogState(() {
                              _isUpdating = false;
                            });
                            return;
                          }

                          if (formKey.currentState!.validate()) {
                            final updatedData = {
                              'farmerName': farmerNameController.text.trim(),
                              'phone': phoneController.text.trim().toString(),
                              'address': addressController.text.trim(),
                              'quantityKg': double.tryParse(
                                      quantityKgController.text.trim()) ??
                                  0,
                              'pricePerKg': int.tryParse(
                                      pricePerKgController.text.trim()) ??
                                  0,
                            };

                            try {
                              await context
                                  .read<InputExpenseViewModel>()
                                  .updateExpenseReport(
                                    id: detail.id.toString(),
                                    updateData: updatedData,
                                  );

                              await context
                                  .read<InputExpenseViewModel>()
                                  .fetchExpenseReport();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Detail berhasil diperbarui'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.error,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child:
                                                Text('Gagal mengupdate: $e')),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                );
                              }
                            }

                            setDialogState(() {
                              _isUpdating = false;
                            });

                            print("isUpdating: " + _isUpdating.toString());
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: _isUpdating
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Menyimpan...'),
                          ],
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

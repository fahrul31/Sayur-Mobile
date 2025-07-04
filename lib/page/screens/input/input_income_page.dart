import 'package:flutter/material.dart';
import 'package:green_finance/viewmodels/input_income_view_model.dart';
import 'package:provider/provider.dart';

class InputIncomePage extends StatefulWidget {
  static const String routeName = '/input-income';

  const InputIncomePage({super.key});

  @override
  _InputIncomePageState createState() => _InputIncomePageState();
}

class _InputIncomePageState extends State<InputIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _totalQuantityKgController =
      TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Map<String, TextEditingController>> _details = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _totalQuantityKgController.dispose();
    _totalPriceController.dispose();
    _noteController.dispose();

    for (var detail in _details) {
      detail['buyerName']?.dispose();
      detail['quantityKg']?.dispose();
      detail['pricePerKg']?.dispose();
      detail['note']?.dispose();
    }

    super.dispose();
  }

  void _addDetail() {
    setState(() {
      _details.add({
        'buyerName': TextEditingController(),
        'quantityKg': TextEditingController(),
        'pricePerKg': TextEditingController(),
        'note': TextEditingController(),
      });
    });
  }

  void _removeDetail(int index) {
    // Dispose controllers before removing
    _details[index]['buyerName']?.dispose();
    _details[index]['quantityKg']?.dispose();
    _details[index]['pricePerKg']?.dispose();
    _details[index]['note']?.dispose();

    setState(() {
      _details.removeAt(index);
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Berhasil!'),
          ],
        ),
        content: const Text('Laporan pendapatan berhasil dibuat'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Back to previous page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isLoading) return; // Prevent double submission

    final viewModel = context.read<InputIncomeViewModel>();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare income details
        List<Map<String, dynamic>> incomesDetails = [];

        // Add main data as primary income detail

        final mainBuyerName = _itemNameController.text.trim();
        final mainQuantity =
            double.tryParse(_totalQuantityKgController.text.trim()) ?? 0;
        final mainPrice = int.tryParse(_totalPriceController.text.trim()) ?? 0;
        final mainNote = _noteController.text.trim();

        final mainDetail = {
          'buyerName': mainBuyerName,
          'quantityKg': mainQuantity,
          'pricePerKg': mainPrice,
        };

        if (mainNote.isNotEmpty) {
          mainDetail['note'] = mainNote;
        }

        incomesDetails.add(mainDetail);

        for (var detail in _details) {
          final buyerName = detail['buyerName']?.text.trim() ?? '';
          final quantityKg =
              double.tryParse(detail['quantityKg']?.text ?? '0') ?? 0;
          final pricePerKg =
              int.tryParse(detail['pricePerKg']?.text ?? '0') ?? 0;
          final note = detail['note']?.text.trim() ?? '';

          if (buyerName.isNotEmpty && quantityKg > 0 && pricePerKg > 0) {
            final detailMap = {
              'buyerName': buyerName,
              'quantityKg': quantityKg,
              'pricePerKg': pricePerKg,
            };

            // ✅ Hanya tambahkan 'note' jika ada isinya
            if (note.isNotEmpty) {
              detailMap['note'] = note;
            }

            incomesDetails.add(detailMap);
          }
        }

        // incomesDetails.add({
        //   'buyerName': _itemNameController.text.trim(),
        //   'quantityKg':
        //       double.tryParse(_totalQuantityKgController.text.trim()) ?? 0,
        //   'pricePerKg': int.tryParse(_totalPriceController.text.trim()) ?? 0,
        //   'note': _noteController.text.trim(),
        // });

        // // Add all additional details
        // for (var detail in _details) {
        //   final buyerName = detail['buyerName']?.text.trim() ?? '';
        //   final quantityKg =
        //       double.tryParse(detail['quantityKg']?.text ?? '0') ?? 0;
        //   final pricePerKg =
        //       int.tryParse(detail['pricePerKg']?.text ?? '0') ?? 0;
        //   final note = detail['note']?.text.trim() ?? '';

        //   if (buyerName.isNotEmpty && quantityKg > 0 && pricePerKg > 0) {
        //     incomesDetails.add({
        //       'buyerName': buyerName,
        //       'quantityKg': quantityKg,
        //       'pricePerKg': pricePerKg,
        //       'note': note,
        //     });
        //   }
        // }

        await viewModel.createIncomeReport(incomesDetails: incomesDetails);

        if (viewModel.errorMessage.isNotEmpty) {
          _showErrorSnackBar(viewModel.errorMessage);
        } else {
          _showSuccessDialog();
        }
      } catch (e) {
        _showErrorSnackBar('$e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Catatan Pendapatan',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Data Pembeli Utama',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Isi data pembeli utama terlebih dahulu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main form
                    _buildInputField(
                      controller: _itemNameController,
                      label: 'Nama Pembeli',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pembeli wajib diisi';
                        } else if (value.trim().length > 30) {
                          return 'Nama pembeli maksimal 30 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _totalQuantityKgController,
                      label: 'Jumlah (Kg)',
                      icon: Icons.scale,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah wajib diisi';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Jumlah harus berupa angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _totalPriceController,
                      label: 'Harga Jual/Kg',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga total wajib diisi';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Harga harus berupa angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _noteController,
                      label: 'Catatan (Opsional)',
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Additional buyers section
                    if (_details.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.group, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Pembeli Tambahan (${_details.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Detail forms
                    for (int i = 0; i < _details.length; i++)
                      _buildDetailForm(i),

                    // Add detail button
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _addDetail,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Pembeli Lain'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Simpan Catatan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Menyimpan laporan...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
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
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Widget _buildDetailForm(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pembeli ${index + 2}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeDetail(index),
                  tooltip: 'Hapus pembeli',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _details[index]['buyerName']!,
              label: 'Nama Pembeli',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama pembeli wajib diisi';
                } else if (value.trim().length > 30) {
                  return 'Nama pembeli maksimal 30 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _details[index]['quantityKg']!,
                    label: 'Jumlah (Kg)',
                    icon: Icons.scale,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      } else if (value.trim().length > 6) {
                        return 'Jumlah maksimal 6 karakter';
                      } else if (value.trim() == '0' || value.trim() == '0.0') {
                        return 'Jumlah tidak boleh 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    controller: _details[index]['pricePerKg']!,
                    label: 'Harga Jual/Kg',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Harus angka positif';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _details[index]['note']!,
              label: 'Catatan (Opsional)',
              icon: Icons.note_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

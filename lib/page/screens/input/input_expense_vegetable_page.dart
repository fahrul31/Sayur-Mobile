import 'package:flutter/material.dart';
import 'package:green_finance/viewmodels/input_expense_view_model.dart';
import 'package:provider/provider.dart';

class InputExpenseVegetablePage extends StatefulWidget {
  static const String routeName = '/input-Expense';

  const InputExpenseVegetablePage({super.key});

  @override
  _InputExpenseVegetablePageState createState() =>
      _InputExpenseVegetablePageState();
}

class _InputExpenseVegetablePageState extends State<InputExpenseVegetablePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _quantityKgController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();

  List<Map<String, TextEditingController>> _details = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _farmerNameController.dispose();
    _quantityKgController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pricePerKgController.dispose();

    for (var detail in _details) {
      detail['farmerName']?.dispose();
      detail['phone']?.dispose();
      detail['address']?.dispose();
      detail['quantityKg']?.dispose();
      detail['pricePerKg']?.dispose();
    }

    super.dispose();
  }

  void _addDetail() {
    setState(() {
      _details.add({
        'farmerName': TextEditingController(),
        'phone': TextEditingController(),
        'address': TextEditingController(),
        'quantityKg': TextEditingController(),
        'pricePerKg': TextEditingController(),
      });
    });
  }

  void _removeDetail(int index) {
    // Dispose controllers before removing
    _details[index]['farmerName']?.dispose();
    _details[index]['phone']?.dispose();
    _details[index]['address']?.dispose();
    _details[index]['quantityKg']?.dispose();
    _details[index]['pricePerKg']?.dispose();

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

    final viewModel = context.read<InputExpenseViewModel>();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare Expense details
        List<Map<String, dynamic>> expensesDetails = [];

        // Add main data as primary Expense detail
        expensesDetails.add({
          'farmerName': _farmerNameController.text.trim(),
          'phone': _phoneController.text.trim().toString(),
          'address': _addressController.text.trim(),
          'quantityKg': double.tryParse(_quantityKgController.text.trim()) ?? 0,
          'pricePerKg': int.tryParse(_pricePerKgController.text.trim()) ?? 0,
        });

        // Add all additional details
        for (var detail in _details) {
          final farmerName = detail['farmerName']?.text.trim() ?? '';
          final phone = detail['phone']?.text.trim() ?? '';
          final address = detail['address']?.text.trim() ?? '';
          final quantityKg =
              double.tryParse(detail['quantityKg']?.text ?? '0') ?? 0;
          final pricePerKg =
              int.tryParse(detail['pricePerKg']?.text ?? '0') ?? 0;

          if (farmerName.isNotEmpty && quantityKg > 0 && pricePerKg > 0) {
            expensesDetails.add({
              'farmerName': farmerName,
              'phone': phone,
              'address': address,
              'quantityKg': quantityKg,
              'pricePerKg': pricePerKg,
            });
          }
        }

        await viewModel.createExpenseVegetableReport(
          expensesDetails: expensesDetails,
        );

        if (viewModel.errorMessage.isNotEmpty) {
          _showErrorSnackBar(viewModel.errorMessage);
        } else {
          _showSuccessDialog();
        }
      } catch (e) {
        _showErrorSnackBar('Gagal membuat laporan: $e');
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
          'Tambah Catatan Pengeluaran',
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
                                'Catatan Pengeluaran',
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
                            'Isi data berikut untuk membuat catatan pengeluaran utama terlebih dahulu',
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
                      controller: _farmerNameController,
                      label: 'Nama Petani',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama petani wajib diisi';
                        } else if (value.trim().length > 30) {
                          return 'Nama petani maksimal 30 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _phoneController,
                      label: 'No. Telfon',
                      icon: Icons.phone,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'No. telfon wajib diisi';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _addressController,
                      label: 'Alamat',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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

                    _buildInputField(
                      controller: _quantityKgController,
                      label: 'Jumlah (Kg)',
                      icon: Icons.scale,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah wajib diisi';
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

                    _buildInputField(
                      controller: _pricePerKgController,
                      label: 'Harga Beli/Kg',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harga total wajib diisi';
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
                              'Petani Tambahan (${_details.length})',
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
                        label: const Text('Tambah Petani Lain'),
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
                  'Petani ${index + 2}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeDetail(index),
                  tooltip: 'Hapus petani',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _details[index]['farmerName']!,
              label: 'Nama Petani',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama petani wajib diisi';
                } else if (value.trim().length > 30) {
                  return 'Nama petani maksimal 30 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _details[index]['phone']!,
              label: 'No. Telfon',
              keyboardType: TextInputType.number,
              icon: Icons.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'No. telfon wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _details[index]['address']!,
              label: 'Alamat',
              icon: Icons.location_on,
              validator: (value) {
                if (value == null || value.isEmpty) {
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
                    label: 'Harga Beli/Kg',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

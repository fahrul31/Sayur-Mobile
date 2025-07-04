import 'dart:io';

import 'package:flutter/material.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:green_finance/page/components/custom_text_field.dart';
import 'package:green_finance/utils/url_to_file.dart';
import 'package:green_finance/viewmodels/item_view_model.dart';
import 'package:green_finance/viewmodels/lov_item_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddItemPage extends StatefulWidget {
  static const String routeName = '/add-item';

  final ItemModel? item;

  const AddItemPage({super.key, this.item});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  ItemModel? _selectedItem;
  String? _selectedType;
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _selectedType = widget.item!.type;
    }

    Future.microtask(() {
      final viewModel = context.read<LovItemViewModel>();
      viewModel.fetchLovItems();
    });
  }

  Future<void> _handleSelectItem(ItemModel selectedItem) async {
    final file = await urlToFile(selectedItem.photo ?? '');
    setState(() {
      _selectedItem = selectedItem;
      _imageFile = file;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Pilih Gambar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Item Selection
            // Item Selection
            Consumer<LovItemViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (viewModel.lovItems.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tidak ada data item',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: DropdownButtonFormField<ItemModel>(
                      value: _selectedItem,
                      hint: const Text('Pilih Lov Item terlebih dahulu'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.inventory_2_outlined),
                        labelText: 'Pilih dari LOV Item (opsional)',
                        helperText:
                            'Atau unggah gambar dari galeri jika tidak tersedia di daftar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: viewModel.lovItems.map((item) {
                        return DropdownMenuItem<ItemModel>(
                          value: item,
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (ItemModel? newValue) async {
                        if (newValue != null && newValue.photo != null) {
                          await _handleSelectItem(newValue);
                        } else {
                          setState(() {
                            _selectedItem = newValue;
                            _imageFile = null;
                          });
                        }
                      }),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () => _selectImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final viewModel = context.read<ItemViewModel>();
    final name = _nameController.text.trim();
    final type = _selectedType;

    print("name: $name");
    print("type: $type");
    print("imageFile: $_imageFile");

    if (name.isEmpty || type == null) {
      _showSnackBar("Nama dan jenis wajib diisi", isError: true);
      return;
    }

    setState(() => context.read<ItemViewModel>().isLoading = true);

    try {
      if (widget.item == null) {
        File? fileToUpload;

        if (_imageFile != null) {
          fileToUpload = _imageFile;
        } else if (_selectedItem?.photo != null) {
          fileToUpload = await urlToFile(_selectedItem!.photo!);
        }

        print("fileToUpload: $fileToUpload");

        if (fileToUpload == null) {
          throw Exception("Gambar wajib dipilih");
        }
        await viewModel.createItemWithPhoto(name, type, fileToUpload.path);
      } else {
        if (_imageFile != null) {
          print("masuk pada update with photo:");
          await viewModel.updateItemWithPhoto(
            widget.item!.id,
            name,
            type,
            _imageFile!.path,
          );
        } else {
          await viewModel.updateItem(widget.item!.id, {
            'name': name,
            'type': type,
          });
        }
      }

      if (mounted) {
        _showSnackBar(
          widget.item == null
              ? "Item berhasil ditambahkan"
              : "Item berhasil diperbarui",
          isError: false,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar("Gagal menyimpan data: $e", isError: true);
    } finally {
      setState(() => context.read<ItemViewModel>().isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    bool isLoading = context.watch<ItemViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Item" : "Tambah Item",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Upload Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  // Image Preview
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (isEdit && widget.item!.photo != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    widget.item!.photo!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambah Foto',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Upload Button
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: Text(_imageFile != null || isEdit
                        ? 'Ganti Foto'
                        : 'Pilih Foto'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Format: JPG, PNG, JPEG (Max 5MB)",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form Card
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Title
                    const Row(
                      children: [
                        Icon(
                          Icons.edit_note,
                          color: Color(0xFF2E7D32),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Informasi Item",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Name Field
                    CustomTextField(
                      hintText: 'Nama Item',
                      icon: Icons.shopping_basket,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama item tidak boleh kosong';
                        } else if (value.trim().length < 3) {
                          return 'Nama item minimal 3 karakter';
                        } else if (value.trim().length > 20) {
                          return 'Nama item maksimal 20 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.category,
                          color: Color(0xFF4CAF50),
                        ),
                        hintText: 'Pilih Jenis',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'VEGETABLE',
                          child: Text('Sayuran'),
                        ),
                        DropdownMenuItem(
                          value: 'OTHER',
                          child: Text('Lainnya'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() async {
                          _selectedType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? "Perbarui Item" : "Simpan Item",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

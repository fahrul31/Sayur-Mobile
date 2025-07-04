import 'package:flutter/material.dart';

/// Tipe function yang menerima ID item dan menghapusnya
typedef DeleteCallback = Future<void> Function(int id);

/// Tipe function untuk edit item (biasanya akan melakukan navigasi)
typedef EditCallback = void Function();

class ActionHandler {
  /// Tampilkan modal aksi (Edit/Hapus)
  static void showActions({
    required BuildContext context,
    required int itemId,
    required String itemName,
    required String? itemPhotoUrl,
    // required EditCallback onEdit,
    required DeleteCallback onDelete,
    required VoidCallback onDeleted, // Refresh list setelah delete
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ListTile(
            //   leading: const Icon(Icons.edit),
            //   title: const Text('Edit'),
            //   onTap: () {
            //     Navigator.pop(context);
            // onEdit();
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, itemId, itemName, onDelete, onDeleted);
              },
            ),
          ],
        );
      },
    );
  }

  /// Konfirmasi penghapusan
  static void _confirmDelete(
    BuildContext context,
    int itemId,
    String itemName,
    DeleteCallback onDelete,
    VoidCallback onDeleted,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                try {
                  await onDelete(itemId); // 🔁 Panggil fungsi delete
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item berhasil dihapus')),
                  );
                  onDeleted(); // Refresh tampilan
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<File> urlToFile(String imageUrl) async {
  // Ambil response dari URL
  final response = await http.get(Uri.parse(imageUrl));

  // Ambil direktori sementara
  final tempDir = await getTemporaryDirectory();

  // Buat nama file dari URL
  final fileName = basename(imageUrl); // butuh package: path

  // Buat file lokal
  final file = File('${tempDir.path}/$fileName');

  // Tulis data
  await file.writeAsBytes(response.bodyBytes);

  return file;
}

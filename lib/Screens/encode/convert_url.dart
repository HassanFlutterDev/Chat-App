// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<File> getImageFromUrl(String url) async {

  final response = await http.get(Uri.parse(url));
  final Directory tempDir = await getTemporaryDirectory();
  final File file = File('${tempDir.path}/temp.jpg');
  await file.writeAsBytes(response.bodyBytes);
  return file;
}
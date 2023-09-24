import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChatMessage {
  String sender;
  String message;
  DateTime timestamp;

  ChatMessage(
      {required this.sender, required this.message, required this.timestamp});
}

class ChatExporter {
  List<ChatMessage> chatMessages = [
    ChatMessage(
      sender: "John",
      message: "Hello",
      timestamp: DateTime.now(),
    ),
    ChatMessage(
      sender: "Alice",
      message: "Hi, how are you?",
      timestamp: DateTime.now().add(Duration(minutes: 5)),
    ),
    // Add more chat messages here
  ];

  Future<void> exportChat() async {
    final exportData = [
      {
        'You': 'Hi\n',
        'Hassan': 'Hi\n',
      },
      {
        'You': 'How are you?\n',
        'Hassan': 'I am Fine\n',
      }
    ];
    ;

    final exportJson = jsonEncode(exportData);

    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/chat_export.txt';

    final file = File(filePath);
    await file.writeAsString(exportJson);
    XFile file1 = new XFile(file.path);
    // Share the export file
    Share.shareFiles([file.path]);
  }
}

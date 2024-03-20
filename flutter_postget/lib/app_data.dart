import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_postget/layout_desktop.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  bool loadingGet = false;
  bool loadingPost = false;
  bool loadingFile = false;

  var url = 'http://localhost:3000/data';

  dynamic dataGet;
  dynamic dataPost;
  dynamic dataFile;
  String imagen = "";

  List<String> _messages = [];

  List<String> get messages => _messages;

  // Function to add a message
  void addMessage(String message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<String> sendTextToServer(String url, String text) async {
    try {
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri)
        ..fields['data'] = jsonEncode({'type': 'mistral', 'mensaje': text});
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = utf8.decode(responseData);
        return responseString;
      } else {
        throw Exception(
            "Failed to send data. Server responded with status code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to send data: $e");
    }
  }

  Future<String> sendImageToServer(
      String url, String imageBase64, String prompt) async {
    try {
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri)
        ..fields['data'] = jsonEncode(
            {'type': 'llava', 'mensaje': imageBase64, 'prompt': prompt});
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = utf8.decode(responseData);
        return responseString;
      } else {
        throw Exception(
            "Failed to send data. Server responded with status code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to send data: $e");
    }
  }
}

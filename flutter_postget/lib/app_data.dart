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

  List<String> _messages = [];

  List<String> get messages => _messages;

  // Function to add a message
  void addMessage(String message) {
    _messages.add(message);
    notifyListeners(); // Notify listeners to update the UI
  }

  // Funció per fer crides tipus 'GET' i agafar la informació a mida que es va rebent
  Future<String> loadHttpGetByChunks(String url) async {
    var httpClient = HttpClient();
    var completer = Completer<String>();
    String result = "";

    // If development, wait 1 second to simulate a delay
    if (!kReleaseMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();

      response.transform(utf8.decoder).listen(
        (data) {
          // Aquí rep cada un dels troços de dades que envia el servidor amb 'res.write'
          result += data;
        },
        onDone: () {
          completer.complete(result);
        },
        onError: (error) {
          completer.completeError(
              "Error del servidor (appData/loadHttpGetByChunks): $error");
        },
      );
    } catch (e) {
      completer.completeError("Excepció (appData/loadHttpGetByChunks): $e");
    }

    return completer.future;
  }

  // Funció per fer crides tipus 'POST' amb un arxiu adjunt,
  //i agafar la informació a mida que es va rebent
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
}

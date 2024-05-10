import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'app_data.dart'; // Asegúrate de que esta ruta sea correcta y apunte a tu archivo AppData

class LayoutDesktop extends StatefulWidget {
  const LayoutDesktop({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LayoutDesktop> createState() => _LayoutDesktopState();
}

class _LayoutDesktopState extends State<LayoutDesktop> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool isSending = false; // Variable para controlar el estado del envío

  // Método para seleccionar una imagen y enviarla al servidor
  Future<void> _pickImage() async {
    // Seleccionar imagen desde la galería
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final AppData appData = Provider.of<AppData>(context, listen: false);
      // Leer los bytes de la imagen y codificarlos en base64
      final bytes = await File(image.path).readAsBytes();
      String imageBase64 = base64Encode(bytes);
      appData.imagen = imageBase64;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener la instancia de AppData usando Provider
    AppData appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // ListView para mostrar los mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: appData.messages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListTile(
                    title: Text(appData.messages[index]),
                  ),
                );
              },
            ),
          ),
          // Campo de texto y botones para enviar mensajes y seleccionar imágenes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: "Escribe tu mensaje aquí",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Botón para seleccionar una imagen
                ElevatedButton(
                  onPressed: () => _pickImage(),
                  child: Icon(Icons.image),
                ),
                SizedBox(width: 8),
                // Botón para enviar el mensaje de texto
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          setState(() {
                            isSending = true;
                          });
                          if (_textController.text.isNotEmpty &&
                              appData.imagen.isEmpty) {
                            appData.addMessage("Yo: ${_textController.text}");
                            appData.texto = _textController.text;
                            setState(() {
                              _textController.clear();
                            });
                            var response = await appData.sendTextToServer(
                                'http://localhost:3000/data', appData.texto);
                            Map<String, dynamic> jsonResponse =
                                json.decode(response);
                            String mensaje = jsonResponse["mensaje"];
                            appData.addMessage(mensaje);
                          } else if (_textController.text.isNotEmpty &&
                              appData.imagen.isNotEmpty) {
                            appData.addMessage("Yo: ${_textController.text}");
                            appData.texto = _textController.text;
                            setState(() {
                              _textController.clear();
                            });
                            var response = await appData.sendImageToServer(
                                'http://localhost:3000/data',
                                appData.imagen,
                                appData.texto);
                            Map<String, dynamic> jsonResponse =
                                json.decode(response);
                            String mensaje = jsonResponse["mensaje"];
                            appData.addMessage(mensaje);
                            appData.imagen = "";
                          }
                          setState(() {
                            isSending = false;
                            _textController.clear();
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            }
                          });
                        },
                  child: Text("Enviar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

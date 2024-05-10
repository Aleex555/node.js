import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart'; // Asegúrate de que la ruta al archivo sea correcta
import 'layout_desktop.dart'; // Asegúrate de que la ruta al archivo sea correcta

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<AppData>(
        create: (_) => AppData(),
        child: LayoutDesktop(title: 'Chat IA'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:desafio_flutter/view/login.dart';

void main() {
  const color = Color.fromRGBO(4, 4, 145, 1.0);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const LoginPage(),
    theme: ThemeData(
      hintColor: color,
      primaryColor: color,
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: color)),
        disabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: color)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: color)),
        hintStyle: TextStyle(color: color),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: TextButton.styleFrom(backgroundColor: color),
      ),
    ),
  ));
}

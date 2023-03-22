import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pages/pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final primaryColor = Color.fromRGBO(136, 14, 79, 1);
    final primaryColorDark = Color.fromRGBO(96, 0, 39, 1);
    final primaryColorLight = Color.fromRGBO(188, 71, 123, 1);

    return MaterialApp(
      title: 'Flutter clean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        primaryColorDark: primaryColorDark,
        primaryColorLight: primaryColorLight,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: primaryColorDark),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColorLight)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
          alignLabelWithHint: true,
        ),
        buttonTheme: ButtonThemeData(
          colorScheme: ColorScheme.light(primary: primaryColor),
          buttonColor: primaryColor,
          splashColor: primaryColorLight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          )
        ),
      ),
      home: const LoginPage(null),
    );
  }
}

import 'package:flutter/material.dart';

ThemeData themeData(BuildContext context) => ThemeData(
      // primarySwatch: Colors.black,

      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all<Color>(
              const Color.fromARGB(255, 23, 221, 102))),
      appBarTheme: const AppBarTheme(
        backgroundColor:  Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
      primaryColor: Color(0xFF0D9488)   ,
      secondaryHeaderColor: const Color(0xFF323536),
      fontFamily: 'Poppins',

      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        surface: Colors.black.withOpacity(.16),
        onInverseSurface: const Color.fromRGBO(0, 0, 0, 0.12),
        primary: const Color.fromRGBO(23, 166, 221, 1),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),

      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey,
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor.withOpacity(.3),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 209, 209, 209),
            width: 1.5,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromRGBO(23, 166, 221, .4),
            width: 1.5,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromRGBO(240, 151, 149, 1),
            width: 1.5,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromRGBO(23, 166, 221, .8),
            width: 1.5,
          ),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromRGBO(23, 166, 221, 1)),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.black,
      ),
    );

ThemeData darkThemeData(BuildContext context) => ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromRGBO(23, 166, 221, 1)),
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      secondaryHeaderColor: const Color.fromRGBO(23, 166, 221, 1),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      primaryColor: const Color(0xFFEF1A5A),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: Colors.white.withOpacity(.16),
        primary: const Color.fromRGBO(23, 166, 221, 1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey,
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor.withOpacity(.3),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 209, 209, 209),
            width: 1.5,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromARGB(255, 209, 209, 209),
            width: 1.5,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromRGBO(240, 151, 149, 1),
            width: 1.5,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Color.fromARGB(30, 27, 83, 244),
            width: 1.5,
          ),
        ),
      ),
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Poppins',
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
      ),
      
    );
    

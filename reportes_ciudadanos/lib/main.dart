import 'package:flutter/material.dart';
import 'pantallas/pantalla_inicio.dart';
//import 'pantallas/pantalla_pruebas.dart';

void main() => runApp(const AppReportes());

class AppReportes extends StatelessWidget {
  const AppReportes({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'App de Reportes CDMX',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A374D)),
      scaffoldBackgroundColor: const Color(0xFFF2F2F2),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A374D),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Color(0xFF333333),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: Color(0xFF666666),
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black87,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black45,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      iconTheme: const IconThemeData(size: 18, color: Colors.black87),

      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8),
      ),

      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: Colors.black87,
        collapsedIconColor: Colors.black54,
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    home: const PantallaInicio(),
    //home: const Prueba(),
  );
}

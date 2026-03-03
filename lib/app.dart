import 'package:flutter/material.dart';
import 'screens/search_screen.dart';

class SnackyApp extends StatelessWidget {
  const SnackyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snacky',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const SearchScreen(),
    );
  }
}

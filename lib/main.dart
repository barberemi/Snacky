import 'package:flutter/material.dart';
// Importe ton fichier de recherche ici !
import 'package:snacky/screens/search_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      home: SearchScreen(), // C'est ici que tu dis à l'app de lancer TON écran
    ),
  );
}

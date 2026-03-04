import 'package:flutter/material.dart';

/// Niveau de confiance d'un article, calculé côté API.
enum ConfidenceLevel {
  high,
  medium,
  low,
  unknown;

  static ConfidenceLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'high':
        return ConfidenceLevel.high;
      case 'medium':
        return ConfidenceLevel.medium;
      case 'low':
        return ConfidenceLevel.low;
      default:
        return ConfidenceLevel.unknown;
    }
  }

  String toJson() => name; // "high" | "medium" | "low" | "unknown"

  String get label {
    switch (this) {
      case ConfidenceLevel.high:
        return 'Fiable';
      case ConfidenceLevel.medium:
        return 'Moyen';
      case ConfidenceLevel.low:
        return 'Prudence';
      case ConfidenceLevel.unknown:
        return 'Inconnu';
    }
  }

  Color get color {
    switch (this) {
      case ConfidenceLevel.high:
        return const Color(0xFF2E7D32); // Vert foncé
      case ConfidenceLevel.medium:
        return const Color(0xFFF57C00); // Orange
      case ConfidenceLevel.low:
        return const Color(0xFFC62828); // Rouge foncé
      case ConfidenceLevel.unknown:
        return const Color(0xFF757575); // Gris
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ConfidenceLevel.high:
        return const Color(0xFFE8F5E9); // Vert très clair
      case ConfidenceLevel.medium:
        return const Color(0xFFFFF3E0); // Orange très clair
      case ConfidenceLevel.low:
        return const Color(0xFFFFEBEE); // Rouge très clair
      case ConfidenceLevel.unknown:
        return const Color(0xFFF5F5F5); // Gris très clair
    }
  }

  IconData get icon {
    switch (this) {
      case ConfidenceLevel.high:
        return Icons.verified;
      case ConfidenceLevel.medium:
        return Icons.remove_circle_outline;
      case ConfidenceLevel.low:
        return Icons.warning_amber_rounded;
      case ConfidenceLevel.unknown:
        return Icons.help_outline;
    }
  }
}

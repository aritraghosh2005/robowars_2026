import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

/// Update tag type with associated display color.
enum UpdateTag {
  results,
  alert,
  update,
  highlight,
  info,
  recap;

  String get label {
    switch (this) {
      case UpdateTag.results: return 'RESULTS';
      case UpdateTag.alert: return 'ALERT';
      case UpdateTag.update: return 'UPDATE';
      case UpdateTag.highlight: return 'HIGHLIGHT';
      case UpdateTag.info: return 'INFO';
      case UpdateTag.recap: return 'RECAP';
    }
  }

  Color get color {
    switch (this) {
      case UpdateTag.results: return AppColors.primary;
      case UpdateTag.alert: return const Color(0xFFFF6B2B);
      case UpdateTag.update: return const Color(0xFF2B9EFF);
      case UpdateTag.highlight: return const Color(0xFFFFD700);
      case UpdateTag.info: return const Color(0xFF7B61FF);
      case UpdateTag.recap: return const Color(0xFF2BFFA0);
    }
  }
}

/// A single update/news item shown on the Updates screen.
class UpdateItem {
  final String title;
  final String content;
  final String time;
  final UpdateTag tag;

  const UpdateItem({
    required this.title,
    required this.content,
    required this.time,
    required this.tag,
  });
}

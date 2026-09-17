import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

/// Update tag type with associated display color.
enum UpdateTag {
  results,
  alert,
  update,
  highlight,
  info,
  recap,
  callup,
  notification;

  String get label {
    switch (this) {
      case UpdateTag.results: return 'RESULTS';
      case UpdateTag.alert: return 'ALERT';
      case UpdateTag.update: return 'UPDATE';
      case UpdateTag.highlight: return 'HIGHLIGHT';
      case UpdateTag.info: return 'INFO';
      case UpdateTag.recap: return 'RECAP';
      case UpdateTag.callup: return 'CALL-UP';
      case UpdateTag.notification: return 'NOTIFICATION';
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
      case UpdateTag.callup: return const Color(0xFFFF2B55); // A distinct bright red/pink
      case UpdateTag.notification: return const Color(0xFF00E5FF); // A bright cyan
    }
  }
}

/// A single update/news item shown on the Updates screen.
class UpdateItem {
  final String id;
  final String title;
  final String content;
  final String time; // Can be updated to DateTime later if needed
  final UpdateTag tag;

  const UpdateItem({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.tag,
  });

  factory UpdateItem.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UpdateItem(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      time: data['time'] ?? '',
      tag: _parseTag(data['tag']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'time': time,
      'tag': tag.name,
    };
  }

  static UpdateTag _parseTag(String? tagString) {
    switch (tagString) {
      case 'results': return UpdateTag.results;
      case 'alert': return UpdateTag.alert;
      case 'highlight': return UpdateTag.highlight;
      case 'info': return UpdateTag.info;
      case 'recap': return UpdateTag.recap;
      case 'callup': return UpdateTag.callup;
      case 'notification': return UpdateTag.notification;
      case 'update':
      default:
        return UpdateTag.update;
    }
  }
}

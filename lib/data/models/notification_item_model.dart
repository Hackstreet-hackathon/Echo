import 'package:equatable/equatable.dart';

import 'announcement_model.dart';

/// Notification item for notification center
class NotificationItemModel extends Equatable {
  const NotificationItemModel({
    required this.id,
    required this.title,
    this.body,
    this.announcement,
    this.read = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? body;
  final AnnouncementModel? announcement;
  final bool read;
  final DateTime? createdAt;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      announcement: json['announcement'] != null
          ? AnnouncementModel.fromJson(json['announcement'] as Map<String, dynamic>)
          : null,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (body != null) 'body': body,
      if (announcement != null) 'announcement': announcement!.toJson(),
      'read': read,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? body,
    AnnouncementModel? announcement,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      announcement: announcement ?? this.announcement,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, announcement, read, createdAt];
}

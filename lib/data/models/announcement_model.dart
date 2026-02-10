import 'package:equatable/equatable.dart';

import '../../core/utils/date_utils.dart' as app_utils;
import 'ticket_model.dart';

/// Announcement entity from backend API
class AnnouncementModel extends Equatable {
  const AnnouncementModel({
    required this.name,
    required this.speechRecognized,
    required this.time,
    this.isPWD = false,
    this.ticket,
    this.id,
    this.trainNumber,
    this.status,
    this.type,
    this.priority = 'Low',
  });

  final String? id;
  final String name;
  final String? trainNumber;
  final String? status; // 'On Time', 'Delayed', 'Arrived', 'Cancelled'
  final String? type; // 'arrival', 'departure', 'general'
  final String priority; // 'High', 'Medium', 'Low'
  final bool isPWD;
  final TicketModel? ticket;
  final String speechRecognized;
  final String time;

  DateTime? get parsedTime => app_utils.AppDateUtils.parseIso8601(time);

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown',
      trainNumber: json['train_number'] as String?,
      status: json['status'] as String?,
      type: json['type'] as String?,
      priority: json['priority'] as String? ?? 'Low',
      isPWD: json['isPWD'] as bool? ?? false,
      ticket: json['ticket'] != null
          ? TicketModel.fromJson(json['ticket'] as Map<String, dynamic>)
          : null,
      speechRecognized:
          json['speech_recognized'] as String? ?? json['speechRecognized'] as String? ?? '',
      time: json['time'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (trainNumber != null) 'train_number': trainNumber,
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      'priority': priority,
      'isPWD': isPWD,
      if (ticket != null) 'ticket': ticket!.toJson(),
      'speech_recognized': speechRecognized,
      'time': time,
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? name,
    bool? isPWD,
    TicketModel? ticket,
    String? speechRecognized,
    String? time,
    String? priority,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isPWD: isPWD ?? this.isPWD,
      ticket: ticket ?? this.ticket,
      speechRecognized: speechRecognized ?? this.speechRecognized,
      time: time ?? this.time,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [id, name, isPWD, ticket, speechRecognized, time, priority];
}

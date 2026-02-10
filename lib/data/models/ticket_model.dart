import 'package:equatable/equatable.dart';

/// Ticket info for train/platform filtering
class TicketModel extends Equatable {
  const TicketModel({
    required this.trainNo,
    required this.platform,
  });

  final String trainNo;
  final int platform;

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      trainNo: json['train_no'] as String? ?? json['trainNo'] as String? ?? '',
      platform: (json['platform'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'train_no': trainNo,
      'platform': platform,
    };
  }

  @override
  List<Object?> get props => [trainNo, platform];
}

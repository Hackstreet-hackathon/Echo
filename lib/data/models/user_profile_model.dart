import 'package:equatable/equatable.dart';

import 'ticket_model.dart';

/// User profile for personalization
class UserProfileModel extends Equatable {
  const UserProfileModel({
    this.id,
    this.phone,
    this.displayName,
    this.isPWD = false,
    this.disabilityDetails,
    this.ticket,
    this.preferredTrainNo,
    this.preferredPlatform,
  });

  final String? id;
  final String? phone;
  final String? displayName;
  final bool isPWD;
  final String? disabilityDetails;
  final TicketModel? ticket;
  final String? preferredTrainNo;
  final int? preferredPlatform;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String?,
      phone: json['phone'] as String?,
      displayName: json['display_name'] as String? ?? json['displayName'] as String?,
      isPWD: json['isPWD'] as bool? ?? json['is_pwd'] as bool? ?? false,
      disabilityDetails: json['disability_details'] as String? ?? json['disabilityDetails'] as String?,
      ticket: json['ticket'] != null
          ? TicketModel.fromJson(json['ticket'] as Map<String, dynamic>)
          : null,
      preferredTrainNo: json['preferred_train_no'] as String? ?? json['preferredTrainNo'] as String?,
      preferredPlatform: (json['preferred_platform'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (phone != null) 'phone': phone,
      if (displayName != null) 'display_name': displayName,
      'isPWD': isPWD,
      if (disabilityDetails != null) 'disability_details': disabilityDetails,
      if (ticket != null) 'ticket': ticket!.toJson(),
      if (preferredTrainNo != null) 'preferred_train_no': preferredTrainNo,
      if (preferredPlatform != null) 'preferred_platform': preferredPlatform,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? phone,
    String? displayName,
    bool? isPWD,
    String? disabilityDetails,
    TicketModel? ticket,
    String? preferredTrainNo,
    int? preferredPlatform,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      isPWD: isPWD ?? this.isPWD,
      disabilityDetails: disabilityDetails ?? this.disabilityDetails,
      ticket: ticket ?? this.ticket,
      preferredTrainNo: preferredTrainNo ?? this.preferredTrainNo,
      preferredPlatform: preferredPlatform ?? this.preferredPlatform,
    );
  }

  @override
  List<Object?> get props =>
      [id, phone, displayName, isPWD, disabilityDetails, ticket, preferredTrainNo, preferredPlatform];
}

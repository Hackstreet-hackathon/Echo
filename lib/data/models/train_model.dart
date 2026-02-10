import 'package:equatable/equatable.dart';

class TrainModel extends Equatable {
  const TrainModel({
    required this.number,
    required this.name,
    required this.from,
    required this.to,
  });

  final String number;
  final String name;
  final String from;
  final String to;

  factory TrainModel.fromJson(Map<String, dynamic> json) {
    return TrainModel(
      number: json['number'] as String,
      name: json['name'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'from': from,
      'to': to,
    };
  }

  String get displayName => '$number - $name';

  @override
  List<Object?> get props => [number, name, from, to];
}

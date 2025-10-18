import 'hpp_calculator.dart';

class HppHistory {
  final String id;
  final String namaProduk;
  final HppCalculator calculator;
  final DateTime timestamp;

  HppHistory({
    required this.id,
    required this.namaProduk,
    required this.calculator,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaProduk': namaProduk,
      'calculator': calculator.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HppHistory.fromJson(Map<String, dynamic> json) {
    return HppHistory(
      id: json['id'],
      namaProduk: json['namaProduk'],
      calculator: HppCalculator.fromJson(json['calculator']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
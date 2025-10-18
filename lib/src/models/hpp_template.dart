import 'hpp_calculator.dart';

class HppTemplate {
  final String id;
  final String namaProduk;
  final HppCalculator calculator;
  final DateTime timestamp;

  HppTemplate({
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

  factory HppTemplate.fromJson(Map<String, dynamic> json) {
    return HppTemplate(
      id: json['id'],
      namaProduk: json['namaProduk'],
      calculator: HppCalculator.fromJson(json['calculator']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
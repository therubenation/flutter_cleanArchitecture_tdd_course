import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable {
  final String text;
  final int number;

  const NumberTrivia({required this.text, required this.number});

  @override
  List<Object?> get props => [text, number];

  factory NumberTrivia.fromJson(Map<String, dynamic> json) {
    final content = json['contents']['numbers'][0];
    return NumberTrivia(number: content['number'], text: content['fact']);
  }
}

import '../../domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  NumberTriviaModel({required String text, required int number})
    : super(text: text, number: number);

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(
      text: json['text'],
      number: (json['number'] as num)
          .toInt(), // using "as num" allows for both int and double to pass test
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'number': number};
  }
}

import '../../domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({required int number, required String text})
    : super(number: number, text: text);

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('text') && json.containsKey('number')) {
      return NumberTriviaModel(
        text: json['text'],
        number: (json['number'] as num)
            .toInt(), // using "as num" allows for both int and double to pass test
      );
    }
    if (json['contents'] is Map<String, dynamic>) {
      final c = json['contents'] as Map<String, dynamic>;
      return NumberTriviaModel(
        number: (c['number'] as num).toInt(),
        text: c['fact'] as String,
      );
    }
    throw const FormatException('Unsupported JSON shape');
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'number': number};
  }

  /*static int _asInt(Object? v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v == null) throw const FormatException('number is null');
    final s = v.toString();
    final i = int.tryParse(s);
    if (i != null) return i;
    final d = double.tryParse(s);
    if (d != null) return d.toInt();
    throw FormatException('Cannot parse number: $s');
  }*/
}

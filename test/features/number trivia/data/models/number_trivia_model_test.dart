import 'dart:convert';

import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  test('should be a subclass of NumberTrivia entity', () async {
    // assert
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  // test for method fromJson:
  group('fromJson', () {
    test('should return valid model when JSON number is an integer', () {
      // Arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));

      // Act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tNumberTriviaModel));
    });
    test(
      'should return valid model when JSON number is regarded as a double',
      () {
        // NO Assert weil: es muss nichts "gerufen" werden

        // Arrange
        final Map<String, dynamic> jsonMap = json.decode(
          fixture('trivia_double.json'),
        );

        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);

        // Assert
        expect(result, equals(tNumberTriviaModel));
      },
    );
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // Arrange

      // Act
      final result = tNumberTriviaModel.toJson();
      // Assert
      final expectedMap = {"text": "Test Text", "number": 1};
      expect(result, expectedMap);
    });
  });
}

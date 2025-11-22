import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  late GetConcreteNumberTrivia useCase;
  late MockNumberTriviaRepository mockRepo;

  setUp(() {
    mockRepo = MockNumberTriviaRepository();
    useCase = GetConcreteNumberTrivia(repository: mockRepo);
  });

  const testNumber = 1; // which number here is meant? the number passed to the
  final testNumberTrivia = NumberTrivia(text: 'test', number: testNumber);

  test('should get trivia for the number from the repository', () async {
    // arrange
    when(
      mockRepo.getConcreteNumberTrivia(any),
    ).thenAnswer((_) async => Right(testNumberTrivia));

    // act — callable class, positional param object
    final result = await useCase(Params(number: testNumber));

    // assert
    expect(result, Right(testNumberTrivia));
    verify(mockRepo.getConcreteNumberTrivia(testNumber));
    verifyNoMoreInteractions(mockRepo);
  });
}

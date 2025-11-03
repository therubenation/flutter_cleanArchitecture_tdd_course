import 'package:clean_architecture_tdd_course/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';

import 'package:clean_architecture_tdd_course/core/use_cases/use_case.dart';
import 'get_concrete_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  late GetRandomNumberTrivia useCase;
  late MockNumberTriviaRepository mockRepo;

  setUp(() {
    mockRepo = MockNumberTriviaRepository();
    useCase = GetRandomNumberTrivia(repository: mockRepo);
  });

  final testNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test('should get trivia rom the repository', () async {
    // arrange
    when(
      mockRepo.getRandomNumberTrivia(),
    ).thenAnswer((_) async => Right(testNumberTrivia));

    // act — callable class, positional param object
    final result = await useCase(const NoParams());

    // assert
    expect(result, Right(testNumberTrivia));
    verify(mockRepo.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockRepo);
  });
}

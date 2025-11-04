import 'package:clean_architecture_tdd_course/core/platform/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'number_trivia_repository_impl_test.mocks.dart';

/// Das Repository ist der Übersetzer & Entscheider.
/// Es nutzt drei abstrakte Helfer (Remote, Local, Network), um der Domain stabile Ergebnisse zu liefern.

/*// handwritten Mock classes
class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}
class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}*/

@GenerateMocks([
  NumberTriviaRemoteDataSource,
  NumberTriviaLocalDataSource,
  NetworkInfo,
])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  // we group tests based on the tested method
  group('getConcreteNumberTrivia', () {
    //establish variable to keep tests manageable:
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(
      text: 'test trivia',
      number: tNumber,
    );
    final NumberTrivia tNumberTrivia =
        tNumberTriviaModel; // tNumberTriviaModel will be cast into NumberTrivia type

    test('should check if device is online', () async {
      // Arrange
      // when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockNetworkInfo.isConnected).thenAnswer((_) => Future.value(true));

      // Act
      await repository.getConcreteNumberTrivia(tNumber);
      // Assert
      verify(mockNetworkInfo.isConnected); // verify it has been called
    });
  });
}

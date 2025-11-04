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
import 'package:clean_architecture_tdd_course/core/error/failures.dart';

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

  /// TEST

  //establish variable to keep tests manageable:
  final tNumber = 1;
  final tNumberTriviaModel = NumberTriviaModel(
    text: 'test trivia',
    number: tNumber,
  );
  final NumberTrivia tNumberTrivia =
      tNumberTriviaModel; // tNumberTriviaModel will be cast into NumberTrivia type

  // we group tests based on the tested method
  group('getConcreteNumberTrivia', () {
    // beginning of L6: Our goal is just to make this test pas,
    // later we#ll make sense of it adding further tests
    // Erst die minimal wichtige Beobachtung absichern (Online-Check),
    // dann in feineren Tests das Verhalten ausbauen(
    // Remote → Cache, Exceptions → Failures, Offline → Local).
    test('should check if device is online', () async {
      // Arrange
      // when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockNetworkInfo.isConnected).thenAnswer((_) => Future.value(true));
      // 🔧 Add this stub because your repo already calls the remote DS:
      when(
        mockRemoteDataSource.getConcreteNumberTrivia(any),
      ).thenAnswer((_) async => tNumberTriviaModel);

      // Act
      await repository.getConcreteNumberTrivia(tNumber);
      // Assert
      verify(mockNetworkInfo.isConnected); // verify it has been called
    });
  });

  group('device is online', () {
    //final tNumber = 1;
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer(
        (_) => Future.value(true),
      ); // Why ? So we dont have to setup a mockNetwork foe each and every time
    });

    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // Arrange
        when(
          mockRemoteDataSource.getConcreteNumberTrivia(any),
        ).thenAnswer((_) async => tNumberTriviaModel);

        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      },
    );
  });
}

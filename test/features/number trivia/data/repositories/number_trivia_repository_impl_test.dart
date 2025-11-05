import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
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
/// Es nutzt drei abstrakte Helfer (Remote, Local, Network), u m der Domain stabile Ergebnisse zu liefern.

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

  /// Unveränderliche Testdaten gehören i. d. R. nicht in setUp(), sondern außerhalb (top-level oder gruppenlokal).
  /// Test-Objekte/Mocks gehören in setUp(), weil sie pro Testlauf frisch sein sollen.
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

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) => Future.value(true));
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(
          mockNetworkInfo.isConnected,
        ).thenAnswer((_) => Future.value(false));
      });
      body();
    });
  }

  /// TEST

  /// Testdaten
  /// Feste Testdaten wie tNumber, tNumberTriviaModel, tNumberTrivia sind immutable → einmal definieren reicht
  final tNumber = 1;
  final tNumberTriviaModel = NumberTriviaModel(
    text: 'test trivia',
    number: tNumber,
  );
  final NumberTrivia tNumberTrivia =
      tNumberTriviaModel; // tNumberTriviaModel will be cast into NumberTrivia type

  // we group tests based on the tested method
  group('getConcreteNumberTrivia', () {
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

  runTestsOnline(() {
    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // Arrange
        // Warum: Wir definieren das Erwartungsverhalten der äußeren Welt:
        // Wenn das Repo den Remote-Call tätigt, bekommt es das NumberTriviaModel.
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenAnswer(
          (_) async => tNumberTriviaModel,
        ); // returns instance of model setUp above under

        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // Assert
        verify(
          mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
        ); // verifizieren, dass MockRemoteDataSourxe mit der selben nummer gecallt wurde
        expect(
          result,
          equals(Right(tNumberTrivia)),
        ); //note:  doesnt return model anymore but instead the actual entity (becau se: datasources return models, repository should cast it into being an entity!
      },
    );

    test(
      'should cache data locally when the call to remote data source is successful',
      () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenAnswer(
          (_) async => tNumberTriviaModel, // stubbing
        ); // returns instance of model setUp above under

        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia)); // caching
      },
    );

    test(
      'should return server failure when the call to remote data source is unsuccessful',
      () async {
        // arrange
        when(
          mockRemoteDataSource.getConcreteNumberTrivia(tNumber),
        ).thenThrow(ServerException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      },
    );
  });

  runTestsOffline(() {
    test(
      'should return last locally cached data when cached data is present',
      () async {
        // Arrange
        when(
          mockLocalDataSource.getLastNumberTrivia(),
        ).thenAnswer((_) async => tNumberTriviaModel);
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      },
    );

    test(
      'should return CacheFailure when there is no cached data present',
      () async {
        // arrange
        when(
          mockLocalDataSource.getLastNumberTrivia(),
        ).thenThrow(CacheException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      },
    );
  });
}

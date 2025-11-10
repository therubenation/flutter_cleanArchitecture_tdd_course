import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_cached.json')) as Map<String, dynamic>,
    );

    test('returns NumberTrivia from SharedPreferences when present', () async {
      // Arrange
      when(
        mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA),
      ).thenReturn(fixture('trivia_cached.json'));

      // Act
      final result = await dataSource.getLastNumberTrivia();

      // Assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA)).called(1);
      verifyNoMoreInteractions(mockSharedPreferences);
      expect(result, equals(tNumberTriviaModel));
    });

    test('throws CacheException when absent', () {
      // Arrange
      when(
        mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA),
      ).thenReturn(null);

      // Act (Funktions-Referenz, nicht ausführen)
      final call = dataSource.getLastNumberTrivia;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA)).called(1);
      verifyNoMoreInteractions(mockSharedPreferences);
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'test trivia',
    );

    test('should call SharedPreferences to cache the data', () async {
      // Arrange: exakter Key + exakter JSON-String (kein any)
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      when(
        mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA,
          expectedJsonString,
        ),
      ).thenAnswer((_) async => true);

      // Act
      await dataSource.cacheNumberTrivia(tNumberTriviaModel);

      // Assert
      verify(
        mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA,
          expectedJsonString,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockSharedPreferences);
    });
  });
}

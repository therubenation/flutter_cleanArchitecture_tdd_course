import 'dart:convert';
import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'package:http/http.dart' as http;
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
    // registerFallbackValue(FakeUri());
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_math_tools.json')),
    );
    final expectedUri = Uri.parse(
      'https://api.math.tools/numbers/fact?number=$tNumber',
    );
    final expectedHeaders = {'accept': 'application/json'};

    test('should perfrom  a GET request with  exact URI and headers', () async {
      // Arrange
      when(
        mockHttpClient.get(expectedUri, headers: expectedHeaders),
      ).thenAnswer(
        (_) async => http.Response(
          fixture('trivia_math_tools.json'),
          200,
        ), //response code 200 = successful
      );

      // Act
      await dataSource.getConcreteNumberTrivia(tNumber);

      // Assert
      verify(
        mockHttpClient.get(expectedUri, headers: expectedHeaders),
      ).called(1);
    });

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // Arrange
        when(
          mockHttpClient.get(expectedUri, headers: expectedHeaders),
        ).thenAnswer(
          (_) async => http.Response(
            fixture('trivia_math_tools.json'),
            200,
          ), //response code 200 = successful
        );

        // Act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);

        // Assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw ServerException when response code is 404 or other',
      () async {
        // Arrange
        when(
          mockHttpClient.get(expectedUri, headers: expectedHeaders),
        ).thenAnswer(
          (_) async =>
              http.Response('oops', 404), // response code 404 = not found
        );

        // Act
        final call = dataSource.getConcreteNumberTrivia;

        // Assert
        expect(() => call(tNumber), throwsA(isA<ServerException>()));
      },
    );
  });

  // -------------------------------getRandomNumberTrivia() Tests

  group('getRandomNumberTrivia', () {
    late NumberTriviaRemoteDataSourceImpl dataSource;
    late MockClient mockHttpClient;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_math_tools.json')),
    );

    final expectedHeaders = {'accept': 'application/json'};

    setUp(() {
      mockHttpClient = MockClient();
      // Random deterministisch auf 11 pinnen
      dataSource = NumberTriviaRemoteDataSourceImpl(
        client: mockHttpClient,
        randomInt: () => 11,
      );
    });

    final expectedUri = Uri.parse(
      'https://api.math.tools/numbers/fact?number=11',
    );

    // präziser Header-Matcher (kein any)
    final headersMatcher = predicate<Map<String, String>>(
      (h) => h.length == 1 && h['accept'] == 'application/json',
      'headers with only Accept: application/json',
    );

    test('performs GET with exact URI and headers', () async {
      // Arrange
      when(
        mockHttpClient.get(
          expectedUri,
          headers: argThat(headersMatcher, named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(fixture('trivia_math_tools.json'), 200),
      );

      // Act
      await dataSource.getRandomNumberTrivia();

      // Assert
      verify(
        mockHttpClient.get(
          expectedUri,
          headers: argThat(headersMatcher, named: 'headers'),
        ),
      ).called(1);
      verifyNoMoreInteractions(mockHttpClient);
    });

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // Arrange
        when(
          mockHttpClient.get(
            expectedUri,
            headers: argThat(headersMatcher, named: 'headers'),
          ),
        ).thenAnswer(
          (_) async => http.Response(fixture('trivia_math_tools.json'), 200),
        );

        // Act
        final result = await dataSource.getRandomNumberTrivia();

        // Assert
        final expected = NumberTriviaModel.fromJson(
          json.decode(fixture('trivia_math_tools.json'))
              as Map<String, dynamic>,
        );
        expect(result.number, expected.number);
        expect(result.text, expected.text);

        verify(
          mockHttpClient.get(
            expectedUri,
            headers: argThat(headersMatcher, named: 'headers'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);
      },
    );

    test(
      'should throw ServerException when response code is 404 or other',
      () async {
        // Arrange
        when(
          mockHttpClient.get(
            expectedUri,
            headers: argThat(headersMatcher, named: 'headers'),
          ),
        ).thenAnswer((_) async => http.Response('oops', 404));

        // Act + Assert
        expect(
          dataSource.getRandomNumberTrivia(),
          throwsA(isA<ServerException>()),
        );

        /*verify(
          mockHttpClient.get(
            expectedUri,
            headers: argThat(headersMatcher, named: 'headers'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockHttpClient);*/
      },
    );
  });
}

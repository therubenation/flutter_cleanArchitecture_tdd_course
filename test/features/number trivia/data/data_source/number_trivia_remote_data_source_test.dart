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

    /* test(
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
    );*/
  });
}

import 'dart:convert';

import '../../domain/entities/number_trivia.dart';
import '../models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

/// Die Schnittstelle zur Außenwelt (Internet/API) innerhalb des Data Layers.
///
/// Ein niedrigstufiger Datenlieferant: holt Rohdaten von der Zahlen-Trivia-API.
///
abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;
  NumberTriviaRemoteDataSourceImpl({required this.client});
  static const _base = 'https://api.math.tools';

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    final uri = Uri.parse('$_base/numbers/fact?number=$number');
    final headers = {'accept': 'application/json'};

    final response = await client.get(uri, headers: headers);

    // return NumberTriviaModel(number: number, text: ''); // Platzhalter
    return NumberTriviaModel.fromJson(json.decode(response.body));
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    // TODO: implement getRandomNumberTrivia
    throw UnimplementedError();
  }
}

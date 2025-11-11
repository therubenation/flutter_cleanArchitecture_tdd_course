import 'dart:convert';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/number_trivia.dart';
import '../models/number_trivia_model.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

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

typedef IntSupplier = int Function();

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;
  final IntSupplier _nextRandom; // injizierbar für Tests

  NumberTriviaRemoteDataSourceImpl({
    required this.client,
    IntSupplier? randomInt,
  }) : _nextRandom = randomInt ?? (() => Random().nextInt(100) + 1);

  static const _base = 'https://api.math.tools';

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    final uri = Uri.parse('$_base/numbers/fact?number=$number');
    final headers = {'accept': 'application/json'};

    final res = await client.get(uri, headers: headers);
    if (res.statusCode != 200) throw ServerException();

    final map = json.decode(res.body) as Map<String, dynamic>;
    return NumberTriviaModel.fromJson(map);
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    final n = _nextRandom(); // z. B. 11 im Test
    return getConcreteNumberTrivia(n); // delegieren
  }
}

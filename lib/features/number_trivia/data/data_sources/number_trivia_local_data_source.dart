import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/number_trivia.dart';
import '../models/number_trivia_model.dart';

const String CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  // constructor
  late final SharedPreferences sharedPreferences;
  NumberTriviaLocalDataSourceImpl({required this.sharedPreferences});

  // Cache = Text, App = Objekt.
  // cacheNumberTrivia macht Objekt → Text.
  // getLastNumberTrivia macht Text → Objekt ODER Fehlt Text → throws Exception.
  @override
  // Ziel: Liefert die zuletzt lokal gespeicherte Number-Trivia zurück.
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(CACHED_NUMBER_TRIVIA);
    if (jsonString == null) {
      throw CacheException();
    }
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return Future.value(NumberTriviaModel.fromJson(map));
  }

  // Ziel: Überschreibt/aktualisiert lokalen Cache mit letztem erfolgreich erlangtem Datensatz
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) async {
    final jsonStr = json.encode(triviaToCache.toJson());
    await sharedPreferences.setString(CACHED_NUMBER_TRIVIA, jsonStr);
    // optional: wenn du willst, auswerten:
    // final ok = await sharedPreferences.setString(...);
    // if (!ok) throw CacheException(); // nur falls du das wirklich willst
  }
}

import 'failures.dart';

class ServerException implements Exception {
  /*final String message;
  ServerException(this.message);*/
}

class CacheException implements Exception {}

// General Failures

class ServerFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => const <dynamic>[]; //TODO  copied from Failure...correct ?
}

class CacheFailure extends Failure {
  @override
  // TODO: implement props
  List<Object?> get props => const <dynamic>[];
}

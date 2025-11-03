import 'package:clean_architecture_tdd_course/core/use_cases/use_case.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:clean_architecture_tdd_course/core/error/failures.dart';
import 'package:equatable/equatable.dart';

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, Params> {
  final NumberTriviaRepository repository;
  GetConcreteNumberTrivia({required this.repository});

  // formerly called "execute()
  // ermöglicht dass die Klasse wie eine Funktion aufgerufen werden kann
  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return repository.getConcreteNumberTrivia(params.number);
  }
}

// define the parameters which get passed into the call method as a separate class
class Params extends Equatable {
  final int number;
  const Params({required this.number});

  @override
  List<Object?> get props => [number];
}

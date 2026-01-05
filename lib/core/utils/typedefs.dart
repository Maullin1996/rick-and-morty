import 'package:dartz/dartz.dart';
import 'package:prueba_tecnica_1/core/error/failure.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef Result<T> = Either<Failure, T>;

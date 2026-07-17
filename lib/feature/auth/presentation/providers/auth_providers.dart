import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/data/datasources/auth_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:prueba_tecnica_1/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/repositories/auth_repository.dart';
import 'package:prueba_tecnica_1/feature/auth/domain/usecase/auth_use_case.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDatasourceProvider)),
);

final authUseCaseProvider = Provider<AuthUseCase>(
  (ref) => AuthUseCase(ref.read(authRepositoryProvider)),
);

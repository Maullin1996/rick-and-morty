import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_tecnica_1/feature/user/data/datasources/user_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/user/data/datasources/user_remote_datasource_impl.dart';
import 'package:prueba_tecnica_1/feature/user/data/repositories/user_repository_impl.dart';
import 'package:prueba_tecnica_1/feature/user/domain/repositories/user_repository.dart';
import 'package:prueba_tecnica_1/feature/user/domain/usecase/user_use_case.dart';

final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>(
  (ref) => UserRemoteDatasourceImpl(),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    ref.read(userRemoteDatasourceProvider),
    ref.read(authUseCaseProvider),
  ),
);

final userUseCaseProvider = Provider<UserUseCase>(
  (ref) => UserUseCase(ref.read(userRepositoryProvider)),
);

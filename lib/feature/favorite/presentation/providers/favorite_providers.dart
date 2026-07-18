import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_tecnica_1/feature/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/favorite/data/datasources/favorite_remote_datasource_impl.dart';
import 'package:prueba_tecnica_1/feature/favorite/data/repositories/favorite_repository_impl.dart';
import 'package:prueba_tecnica_1/feature/favorite/domain/repositories/favorite_repository.dart';
import 'package:prueba_tecnica_1/feature/favorite/domain/usecase/favorite_use_case.dart';

final favoriteRemoteDatasourceProvider = Provider<FavoriteRemoteDatasource>(
  (ref) => FavoriteRemoteDatasourceImpl(),
);

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepositoryImpl(
    ref.read(favoriteRemoteDatasourceProvider),
    ref.read(authUseCaseProvider),
  ),
);

final favoriteUseCaseProvider = Provider<FavoriteUseCase>(
  (ref) => FavoriteUseCase(ref.read(favoriteRepositoryProvider)),
);

import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/http/http_client.dart';
import 'package:prueba_tecnica_1/feature/home/data/datasources/characters_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/home/data/datasources/characters_remote_datasource_impl.dart';
import 'package:prueba_tecnica_1/feature/home/data/repositories/characters_repository_impl.dart';
import 'package:prueba_tecnica_1/feature/home/domain/repository/characters_repository.dart';
import 'package:prueba_tecnica_1/feature/home/domain/usecase/characters_use_case.dart';

final httpClientProvider = Provider<HttpClient>((ref) {
  return HttpClient(http.Client());
});

final charactersRemoteDatasourceProvider = Provider<CharactersRemoteDatasource>(
  (ref) {
    return CharactersRemoteDatasourceImpl(ref.read(httpClientProvider));
  },
);

final charactersRepositoryProvider = Provider<CharactersRepository>((ref) {
  return CharactersRepositoryImpl(ref.read(charactersRemoteDatasourceProvider));
});

final getCharactersUseCaseProvider = Provider<CharactersUseCase>((ref) {
  return CharactersUseCase(ref.read(charactersRepositoryProvider));
});

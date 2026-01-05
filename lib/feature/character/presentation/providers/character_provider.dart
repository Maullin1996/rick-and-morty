import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/http/http_client.dart';
import 'package:prueba_tecnica_1/feature/character/data/datasources/character_remote_datasource.dart';
import 'package:prueba_tecnica_1/feature/character/data/datasources/character_remote_datasource_impl.dart';
import 'package:prueba_tecnica_1/feature/character/data/repositories/character_repository_impl.dart';
import 'package:prueba_tecnica_1/feature/character/domain/usecase/character_use_case.dart';

final httpClientProvider = Provider<HttpClient>(
  (ref) => HttpClient(http.Client()),
);

final characterRemoteDatasourceProvider = Provider<CharacterRemoteDatasource>(
  (ref) => CharacterRemoteDatasourceImpl(ref.read(httpClientProvider)),
);

final characterRepositoryProvider = Provider<CharacterRepositoryImpl>(
  (ref) => CharacterRepositoryImpl(ref.read(characterRemoteDatasourceProvider)),
);

final getCharacterUseCaseProvider = Provider<CharacterUseCase>(
  (ref) => CharacterUseCase(ref.read(characterRepositoryProvider)),
);

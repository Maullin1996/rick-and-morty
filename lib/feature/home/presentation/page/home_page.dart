import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/feature/auth/presentation/providers/auth_provider.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/helpers/map_status.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/character_search_state.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/providers/characters_state.dart';
import 'package:prueba_tecnica_1/feature/home/presentation/widget/characters_grid.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> status = const ['Todos', 'Vivo', 'Muerto', 'Desconocido'];
  int selectedStatusIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(charactersProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersProvider);
    final searchState = ref.watch(characterSearchProvider);
    final tokens = AppTokens.of(context);
    final color = AppColors.of(context);
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rick And Morty'),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.person_outline, color: color.primary),
              onSelected: (value) {
                if (value == 'login') {
                  context.push('/login');
                } else {
                  ref.read(isLoggedInProvider.notifier).signOut();
                }
              },
              itemBuilder: (context) => [
                if (!isLoggedIn)
                  const PopupMenuItem(
                    value: 'login',
                    child: Text('Iniciar sesión'),
                  )
                else
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Cerrar sesión'),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(tokens.spacing.small),
                child: AppSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(characterSearchProvider.notifier).search(value);
                  },
                  fillColor: color.border,
                  hintText: 'Buscar personaje...',
                ),
              ),
              AppResultSearchBar(
                child: searchState.maybeWhen(
                  loaded: (results) => results.isEmpty
                      ? null
                      : Material(
                          color: Colors.transparent,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, index) {
                              final character = results[index];

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    character.image,
                                  ),
                                ),
                                title: AppText.body(character.name),
                                onTap: () {
                                  ref
                                      .read(characterSearchProvider.notifier)
                                      .clear();
                                  _searchController.clear();
                                  context.push('/character', extra: character.id);
                                },
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemCount: results.length,
                          ),
                        ),
                  orElse: () => null,
                ),
              ),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.small,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: status.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: tokens.spacing.xSmall),
                  itemBuilder: (context, index) {
                    return AppFilterChip(
                      key: Key('status_chip_${status[index].toLowerCase()}'),
                      label: status[index],
                      selected: index == selectedStatusIndex,
                      onSelected: (_) {
                        ref
                            .read(charactersProvider.notifier)
                            .loadInitial(status: mapStatus(index));
                        setState(() => selectedStatusIndex = index);
                      },
                    );
                  },
                ),
              ),

              Expanded(
                child: state.when(
                  initial: () =>
                      const Center(child: CircularProgressIndicator()),
                  loading: (characters) => CharactersGrid(
                    characters: characters,
                    isLoading: true,
                    onRetry: () => ref
                        .read(charactersProvider.notifier)
                        .loadInitial(status: mapStatus(selectedStatusIndex)),
                    onLoadMore: () =>
                        ref.read(charactersProvider.notifier).loadMore(),
                  ),
                  loaded: (characters, hasMore) => CharactersGrid(
                    characters: characters,
                    isLoading: false,
                    onRetry: () => ref
                        .read(charactersProvider.notifier)
                        .loadInitial(status: mapStatus(selectedStatusIndex)),
                    onLoadMore: () =>
                        ref.read(charactersProvider.notifier).loadMore(),
                  ),
                  error: (message, characters) {
                    return CharactersGrid(
                      characters: characters,
                      isLoading: false,
                      errorMessage: message,
                      onRetry: () => ref
                          .read(charactersProvider.notifier)
                          .loadInitial(status: mapStatus(selectedStatusIndex)),
                      onLoadMore: () =>
                          ref.read(charactersProvider.notifier).loadMore(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

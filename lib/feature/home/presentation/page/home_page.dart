import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prueba_tecnica_1/core/tokens/scifi_colors.dart';
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
  final ScrollController _scrollController = ScrollController();

  final List<String> status = const ['Todos', 'Vivo', 'Muerto', 'Desconocido'];
  int selectedStatusIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(charactersProvider.notifier).loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(charactersProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersProvider);
    final searchState = ref.watch(characterSearchProvider);

    return SafeArea(
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Rick And Morty',
            style: TextStyle(
              color: SciFiColors.neonCyan,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.go('/favorite'),
              icon: const Icon(
                Icons.favorite,
                color: SciFiColors.neonCyan,
                size: 30,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(characterSearchProvider.notifier).search(value);
                },
                style: const TextStyle(color: SciFiColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar personaje...',
                  hintStyle: TextStyle(
                    color: SciFiColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: SciFiColors.neonCyan,
                  ),
                  filled: true,
                  fillColor: SciFiColors.deepBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            searchState.when(
              initial: () => const SizedBox.shrink(),
              loading: () =>
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
              loaded: (results) => Container(
                constraints: BoxConstraints(maxHeight: 250),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: SciFiColors.deepBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SciFiColors.success),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    final character = results[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(character.image),
                      ),
                      title: Text(
                        character.name,
                        style: const TextStyle(color: SciFiColors.textPrimary),
                      ),
                      onTap: () {
                        ref.read(characterSearchProvider.notifier).clear();
                        _searchController.clear();
                        context.go('/character', extra: character.id);
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: results.length,
                ),
              ),
              error: (_) => const SizedBox.shrink(),
            ),
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: status.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    key: Key('status_chip_${status[index].toLowerCase()}'),
                    label: Text(status[index]),
                    showCheckmark: false,
                    selected: (index == selectedStatusIndex),
                    onSelected: (_) {
                      ref
                          .read(charactersProvider.notifier)
                          .loadInitial(status: mapStatus(index));
                      setState(() => selectedStatusIndex = index);
                    },
                    selectedColor: SciFiColors.neonCyan,
                    backgroundColor: SciFiColors.deepBlue,
                    labelStyle: TextStyle(
                      color: (index == selectedStatusIndex)
                          ? SciFiColors.textOnNeon
                          : SciFiColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: state.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: (characters) => CharactersGrid(
                  controller: _scrollController,
                  characters: characters,
                  isLoading: true,
                ),
                loaded: (characters, hasMore) => CharactersGrid(
                  controller: _scrollController,
                  characters: characters,
                  isLoading: false,
                ),
                error: (message, characters) {
                  return CharactersGrid(
                    controller: _scrollController,
                    characters: characters,
                    isLoading: false,
                    errorMessage: message,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

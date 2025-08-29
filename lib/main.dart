import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_explorer/favorites_provider.dart';
import 'package:pokedex_explorer/favorites_screen.dart';
import 'package:pokedex_explorer/poke_model.dart';
import 'package:pokedex_explorer/pokemon_screen.dart';
import 'package:pokedex_explorer/utils.dart';
import 'package:provider/provider.dart';

Future<PokemonList> fetchPokemons({int offset = 0, int limit = 20}) async {
  final url = Uri.parse(
    'https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return PokemonList.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Falha ao carregar pokémons.');
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Pokédex Explorer', home: PokedexScreen());
  }
}

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});
  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  late Future<PokemonList> futureFirstPage;
  final List<PokemonBasic> _items = [];
  bool _loadingMore = false;

  int _offset = 0;
  final int _limit = 20;
  bool _noMore = false;

  @override
  void initState() {
    super.initState();
    futureFirstPage = fetchPokemons(offset: _offset, limit: _limit);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _noMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await fetchPokemons(offset: _offset, limit: _limit);
      if (page.pokemonList.isEmpty) {
        setState(() => _noMore = true);
      } else {
        setState(() {
          _items.addAll(page.pokemonList);
          _offset += _limit;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar mais: $e')));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex Explorer')),
      body: Center(
        child: FutureBuilder<PokemonList>(
          future: futureFirstPage,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erro: ${snapshot.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _items.clear();
                          _offset = 0;
                          _noMore = false;
                          futureFirstPage = fetchPokemons(
                            offset: _offset,
                            limit: _limit,
                          );
                        });
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasData && _items.isEmpty) {
              final firstPage = snapshot.data!;
              _items.addAll(firstPage.pokemonList);
              _offset += _limit;
            }

            if (_items.isEmpty) {
              return const Text('Nenhum Pokémon encontrado.');
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final p = _items[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PokemonDetailScreen(id: p.id),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              p.image,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image)),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                color: Colors.black54,
                                child: Text(
                                  cap(p.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'fab-left',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text('Favoritos'),
            ),

            FloatingActionButton.extended(
              heroTag: 'fab-right',
              onPressed: (_loadingMore || _noMore) ? null : _loadMore,
              icon: const Icon(Icons.add),
              label: Text(
                _noMore
                    ? 'Fim da lista'
                    : (_loadingMore ? 'Carregando...' : 'Carregar mais'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

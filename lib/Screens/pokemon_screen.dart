import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex_explorer/Utils/utils.dart';
import '../Models/poke_model.dart';
import 'package:provider/provider.dart';
import '../Providers/favorites_provider.dart';

Future<PokemonDetail> fetchPokemonDetail(int id) async {
  final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$id');
  final res = await http.get(url);
  if (res.statusCode != 200) {
    throw Exception('Falha ao carregar detalhes do Pokémon $id');
  }
  return PokemonDetail.fromJson(jsonDecode(res.body));
}

class StatBar extends StatelessWidget {
  final String label;
  final int value;

  const StatBar({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('$value'),
        ],
      ),
    );
  }
}

class PokemonDetailScreen extends StatelessWidget {
  final int id;
  const PokemonDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Pokémon')),
      body: FutureBuilder<PokemonDetail>(
        future: fetchPokemonDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Erro: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) return const SizedBox.shrink();

          final p = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<FavoritesProvider>(
                  builder: (context, fav, _) {
                    final isFav = fav.isFavorite(p.id);
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            '#${p.id} ${cap(p.name)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: isFav ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () => fav.toggleFavorite(
                            id: p.id,
                            name: p.name,
                            image: p.images.first,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: p.types
                      .map(
                        (t) => Chip(
                          label: Text(
                            cap(t),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: typeColor(t),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Altura",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${p.heightMeters.toStringAsFixed(1)} m'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Peso",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${p.weightKg.toStringAsFixed(1)} kg'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (p.images.isNotEmpty) ...[
                  const Text(
                    'Imagens',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                    itemCount: p.images.length,
                    itemBuilder: (context, i) {
                      final url = p.images[i];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            errorBuilder: (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                const Text(
                  'Estatísticas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                StatBar(label: 'Vida', value: p.stats['hp'] ?? 0),
                StatBar(label: 'Ataque', value: p.stats['attack'] ?? 0),
                StatBar(label: 'Defesa', value: p.stats['defense'] ?? 0),
                StatBar(
                  label: 'Ataque especial',
                  value: p.stats['special-attack'] ?? 0,
                ),
                StatBar(
                  label: 'Defesa especial',
                  value: p.stats['special-defense'] ?? 0,
                ),
                StatBar(label: 'Velocidade', value: p.stats['speed'] ?? 0),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PokemonBasic {
  final int id;
  final String name;
  final String url;
  final String image;

  PokemonBasic({
    required this.id,
    required this.name,
    required this.url,
    required this.image,
  });

  factory PokemonBasic.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    // extração id
    final match = RegExp(r'/pokemon/(\d+)/?$').firstMatch(url);
    final id = int.tryParse(match?.group(1) ?? '') ?? 0;

    final image =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return PokemonBasic(
      id: id,
      name: json['name'] as String,
      url: url,
      image: image,
    );
  }
}

class PokemonList {
  final List<PokemonBasic> pokemonList;

  PokemonList({required this.pokemonList});

  factory PokemonList.fromJson(Map<String, dynamic> json) {
    final formattedList = (json['results'] as List<dynamic>)
        .map<PokemonBasic>(
          (item) => PokemonBasic.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return PokemonList(pokemonList: formattedList);
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final List<String> types;
  final List<String> images;
  final Map<String, int>
  stats; // hp, attack, defense, special-attack, special-defense, speed
  final double heightMeters;
  final double weightKg;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.types,
    required this.images,
    required this.stats,
    required this.heightMeters,
    required this.weightKg,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;

    // tipos
    final types = (json['types'] as List<dynamic>)
        .map((t) => (t as Map<String, dynamic>)['type']['name'] as String)
        .toList();

    // imagens
    final sprites = json['sprites'] as Map<String, dynamic>;
    final other = (sprites['other'] ?? {}) as Map<String, dynamic>;
    final official = (other['official-artwork'] ?? {}) as Map<String, dynamic>;

    final candidates = <String?>[
      official['front_default'] as String?,
      sprites['front_default'] as String?,
      sprites['back_default'] as String?,
      sprites['front_shiny'] as String?,
      sprites['back_shiny'] as String?,
    ];
    final images = candidates.whereType<String>().toList();

    // stats
    final statsList = (json['stats'] as List<dynamic>)
        .map((s) => s as Map<String, dynamic>)
        .toList();
    final Map<String, int> stats = {
      for (final s in statsList)
        (s['stat']['name'] as String): (s['base_stat'] as int),
    };

    // altura/peso
    final heightMeters = ((json['height'] ?? 0) as num).toDouble() / 10.0;
    final weightKg = ((json['weight'] ?? 0) as num).toDouble() / 10.0;

    return PokemonDetail(
      id: id,
      name: name,
      types: types,
      images: images,
      stats: stats,
      heightMeters: heightMeters,
      weightKg: weightKg,
    );
  }
}

class FavoritePokemon {
  final int id;
  final String name;
  final String image; // url

  const FavoritePokemon({
    required this.id,
    required this.name,
    required this.image,
  });
}

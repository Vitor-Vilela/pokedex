import 'package:flutter/material.dart';
import 'package:pokedex_explorer/poke_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<FavoritePokemon> _favorites = [];

  /// Lista somente-leitura de favoritos
  List<FavoritePokemon> get favorites => List.unmodifiable(_favorites);

  /// Lista só de IDs (se precisar em algum lugar)
  List<int> get idsReceitasFavorites => _favorites.map((f) => f.id).toList();

  bool isFavorite(int id) {
    return _favorites.any((f) => f.id == id);
  }

  void toggleFavorite({
    required int id,
    required String name,
    required String image,
  }) {
    final index = _favorites.indexWhere((f) => f.id == id);
    if (index >= 0) {
      // Remove se já existe
      _favorites.removeAt(index);
    } else {
      // Adiciona novo favorito
      _favorites.add(FavoritePokemon(id: id, name: name, image: image));
    }
    notifyListeners();
  }

  void removerFavorite(int id) {
    _favorites.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}

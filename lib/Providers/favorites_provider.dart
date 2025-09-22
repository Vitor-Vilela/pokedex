import 'package:flutter/material.dart';
import 'package:pokedex_explorer/Models/poke_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<FavoritePokemon> _favorites = [];

  List<FavoritePokemon> get favorites => List.unmodifiable(_favorites);

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
      _favorites.removeAt(index);
    } else {
      _favorites.add(FavoritePokemon(id: id, name: name, image: image));
    }
    notifyListeners();
  }

  void removerFavorite(int id) {
    _favorites.removeWhere((f) => f.id == id);
    notifyListeners();
  }
}

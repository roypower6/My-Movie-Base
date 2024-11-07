import 'dart:convert';

import 'package:my_movie_base/model/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_movies';

  Future<List<Movie>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesJson
        .map((json) => Movie.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> toggleFavorite(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    final movieIndex = favoritesJson.indexWhere((json) {
      final existingMovie = Movie.fromJson(jsonDecode(json));
      return existingMovie.id == movie.id;
    });

    if (movieIndex >= 0) {
      favoritesJson.removeAt(movieIndex);
    } else {
      final updatedMovie = movie.copyWith(isFavorite: true);
      favoritesJson.add(jsonEncode(updatedMovie.toJson()));
    }

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<bool> isFavorite(int movieId) async {
    final favorites = await getFavorites();
    return favorites.any((movie) => movie.id == movieId);
  }
}

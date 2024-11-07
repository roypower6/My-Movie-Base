import 'package:flutter/material.dart';
import 'package:my_movie_base/model/movie_model.dart';
import 'package:my_movie_base/services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  List<Movie> _favorites = [];

  List<Movie> get favorites => _favorites;

  Future<void> loadFavorites() async {
    _favorites = await _favoriteService.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Movie movie) async {
    await _favoriteService.toggleFavorite(movie);
    await loadFavorites(); // 즐겨찾기 목록 다시 로드
  }

  Future<bool> isFavorite(int movieId) async {
    return await _favoriteService.isFavorite(movieId);
  }
}

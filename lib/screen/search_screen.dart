import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:my_movie_base/model/movie_model.dart';
import 'package:my_movie_base/screen/movie_detail_screen.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> searchResults = [];
  List<Movie> searchHistory = [];
  bool isLoading = false;
  String? error;

  static const String searchHistoryKey = 'movie_search_history';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(searchHistoryKey) ?? [];

    setState(() {
      searchHistory = historyJson
          .map((json) => Movie.fromJson(jsonDecode(json)))
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> _saveToHistory(Movie movie) async {
    // 영화 상세 정보를 가져와서 장르 정보 업데이트
    try {
      final detailedMovie = await _apiService.getMovieDetails(movie.id);

      final prefs = await SharedPreferences.getInstance();
      List<String> historyJson = prefs.getStringList(searchHistoryKey) ?? [];

      // 중복 제거
      historyJson.removeWhere((json) {
        final existingMovie = Movie.fromJson(jsonDecode(json));
        return existingMovie.id == detailedMovie.id;
      });

      // 최근 검색 영화 추가
      historyJson.add(jsonEncode({
        'id': detailedMovie.id,
        'title': detailedMovie.title,
        'poster_path': detailedMovie.posterPath,
        'release_date': detailedMovie.releaseDate,
        'backdrop_path': detailedMovie.backdropPath,
        'vote_average': detailedMovie.voteAverage,
        'vote_count': detailedMovie.voteCount,
        'overview': detailedMovie.overview,
        'original_language': detailedMovie.originalLanguage,
        'genres': detailedMovie.genres,
        'runtime': detailedMovie.runtime,
      }));

      // 최대 20개까지 저장
      if (historyJson.length > 20) {
        historyJson.removeAt(0);
      }

      await prefs.setStringList(searchHistoryKey, historyJson);
      await _loadSearchHistory();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to history: $e');
      }
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final results = await _apiService.searchMovies(query);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(searchHistoryKey);
    setState(() {
      searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.search_rounded,
          size: 27,
        ),
        title: TextField(
          controller: _searchController,
          onChanged: (value) => searchMovies(value),
          decoration: InputDecoration(
            hintText: '영화 제목을 검색해 보세요!',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        searchResults = [];
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text('Error: $error'));
    }

    if (searchResults.isEmpty) {
      return _buildSearchHistory();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final movie = searchResults[index];
        return _buildMovieTile(movie, fromSearch: true);
      },
    );
  }

  Widget _buildSearchHistory() {
    if (searchHistory.isEmpty) {
      return const Center(
        child: Text(
          '최근 검색한 영화가 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색한 영화',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearSearchHistory,
                child: const Text(
                  '전체 삭제',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              final movie = searchHistory[index];
              return _buildMovieTile(movie, fromSearch: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieTile(Movie movie, {required bool fromSearch}) {
    return ListTile(
      onTap: () async {
        if (fromSearch) {
          await _saveToHistory(movie);
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      leading: movie.posterPath != null
          ? Image.network(
              movie.thumbnailPath,
              width: 50,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.movie, size: 50);
              },
            )
          : const Icon(Icons.movie, size: 50),
      title: Text(
        movie.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        // null 체크 및 기본값 추가
        '${movie.releaseYear.isNotEmpty ? movie.releaseYear : '미정'} · ${movie.genres.isNotEmpty ? movie.genresText : '장르 없음'}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          Text(
              // null 체크 및 기본값 추가
              movie.voteAverage != null ? movie.formattedVoteAverage : '평가 없음'),
        ],
      ),
    );
  }
}

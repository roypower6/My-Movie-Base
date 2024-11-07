import 'package:flutter/material.dart';
import 'package:my_movie_base/model/movie_model.dart';
import 'package:my_movie_base/screen/movie_item.dart';
import 'package:my_movie_base/services/api_service.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  MovieListScreenState createState() => MovieListScreenState();
}

class MovieListScreenState extends State<MovieListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  late Future<List<Movie>> latestMovies;
  late Future<List<Movie>> animationMovies;
  late Future<List<Movie>> actionMovies;
  late Future<List<Movie>> sciFiMovies;
  late Future<List<Movie>> romansMovies;
  late Future<List<Movie>> comedyMovies;
  late Future<List<Movie>> documentaryMovies;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    latestMovies = _apiService.getLatestMovies(); // 최신 영화
    animationMovies = _apiService.getMoviesByGenre(16); // 애니메이션
    actionMovies = _apiService.getMoviesByGenre(28); // 액션
    sciFiMovies = _apiService.getMoviesByGenre(878); // SF
    romansMovies = _apiService.getMoviesByGenre(10749); //로맨스
    comedyMovies = _apiService.getMoviesByGenre(35); //코미디
    documentaryMovies = _apiService.getMoviesByGenre(99);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Movie Base',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 27,
              ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadMovies();
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMovieSection('최신 영화', latestMovies),
              _buildMovieSection('애니메이션', animationMovies),
              _buildMovieSection('액션', actionMovies),
              _buildMovieSection('SF', sciFiMovies),
              _buildMovieSection('로맨스', romansMovies),
              _buildMovieSection('코미디', comedyMovies),
              _buildMovieSection('다큐멘터리', documentaryMovies),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieSection(String title, Future<List<Movie>> futureMovies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 280,
          child: FutureBuilder<List<Movie>>(
            future: futureMovies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No movies available'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final movie = snapshot.data![index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    child: MovieItem(movie: movie),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

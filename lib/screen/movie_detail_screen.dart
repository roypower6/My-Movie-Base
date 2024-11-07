import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_movie_base/model/actor_model.dart';
import 'package:my_movie_base/model/movie_model.dart';
import 'package:my_movie_base/model/review_model.dart';
import 'package:my_movie_base/services/api_service.dart';
import 'package:my_movie_base/services/favorite_provider.dart';
import 'package:my_movie_base/services/favorite_service.dart';
import 'package:provider/provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Movie> _movieDetailsFuture;
  late Future<List<Actor>> _movieCreditsFuture;
  late Future<List<Review>> _movieReviewsFuture;
  late Future<bool> _isFavoriteFuture;
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = _fetchMovieDetails();
    _movieCreditsFuture = _fetchMovieCredits();
    _movieReviewsFuture = _fetchMovieReviews();
    _isFavoriteFuture = _checkFavoriteStatus();
  }

  Future<Movie> _fetchMovieDetails() async {
    final apiService = ApiService();
    return await apiService.getMovieDetails(widget.movie.id);
  }

  Future<List<Actor>> _fetchMovieCredits() async {
    final apiService = ApiService();
    return await apiService.getMovieCredits(widget.movie.id);
  }

  Future<List<Review>> _fetchMovieReviews() async {
    final apiService = ApiService();
    return await apiService.getMovieReviews(widget.movie.id);
  }

  Future<bool> _checkFavoriteStatus() async {
    return await _favoriteService.isFavorite(widget.movie.id);
  }

  void _toggleFavorite() async {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    await favoriteProvider.toggleFavorite(widget.movie);
    setState(() {
      _isFavoriteFuture = _checkFavoriteStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Movie>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                expandedHeight: 400,
                actions: [
                  FutureBuilder<bool>(
                    future: _isFavoriteFuture,
                    builder: (context, favSnapshot) {
                      final isFavorite = favSnapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: _toggleFavorite,
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: widget.movie.posterPath != null
                      ? Image.network(
                          widget.movie.fullPosterPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[850],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[850],
                          child: const Center(
                            child: Icon(
                              Icons.movie_rounded,
                              size: 48,
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (snapshot.hasError)
                        Center(child: Text('Error: ${snapshot.error}'))
                      else if (snapshot.hasData) ...[
                        _buildMovieDetails(context, snapshot.data!),
                        const SizedBox(height: 24),
                        _buildCastSection(),
                        _buildReviewsSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMovieDetails(BuildContext context, Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '개봉일: ${movie.formattedReleaseDate}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '장르: ${movie.genresText}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '언어: ${movie.languageText}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '상영시간: ${movie.formattedRuntime}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        const SizedBox(height: 24),
        Text(
          '줄거리',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview ?? '줄거리 정보가 없습니다.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        if (movie.voteCount != null && movie.voteCount! > 0) ...[
          Text(
            '평가',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 20,
                color: Colors.amber[400],
              ),
              const SizedBox(width: 4),
              Text(
                movie.formattedVoteAverage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                ' / 10',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Text(
                movie.formattedVoteCount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCastSection() {
    return FutureBuilder<List<Actor>>(
      future: _movieCreditsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final actors = snapshot.data!.take(10).toList(); // 상위 10명의 배우만 표시

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주요 출연진',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: actors.map((actor) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: actor.profilePath != null
                              ? NetworkImage(actor.fullProfilePath)
                              : null,
                          child: actor.profilePath == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          actor.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          actor.character,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<List<Review>>(
      future: _movieReviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          if (kDebugMode) {
            print('Review error: ${snapshot.error}'); // 에러 로깅
          }
          return const SizedBox.shrink();
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관람평',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '아직 작성된 관람평이 없습니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '관람평',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Tooltip(
                    showDuration: Duration(seconds: 5),
                    message:
                        "API 제공사 TMDB의 한국어 리뷰 부족으로 인해 \n영어권 리뷰를 제공드리는 점 양해 부탁드립니다.",
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info,
                      size: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...reviews.map((review) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review.author,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (review.rating != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: Colors.amber[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          review.formattedRating,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.formattedDate,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

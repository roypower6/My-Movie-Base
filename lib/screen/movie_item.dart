import 'package:flutter/material.dart';
import 'package:my_movie_base/model/movie_model.dart';
import 'package:my_movie_base/screen/movie_detail_screen.dart';

class MovieItem extends StatelessWidget {
  final Movie movie;

  const MovieItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.posterPath != null
                  ? Image.network(
                      movie.fullPosterPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[850],
                          child: const Center(
                            child: Icon(Icons.error_outline_rounded),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[850],
                      child: const Center(
                        child: Icon(Icons.movie_rounded),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (movie.releaseDate != null) ...[
            const SizedBox(height: 4),
            Text(
              movie.releaseDate!.substring(0, 4),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:my_movie_base/model/actor_model.dart';

class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final String? overview;
  final List<String> genres;
  final String? originalLanguage;
  final int? runtime;
  final List<Actor> actors;
  final bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.overview,
    this.genres = const [],
    this.originalLanguage,
    this.runtime,
    this.actors = const [],
    this.isFavorite = false,
  });

  Movie copyWith({
    int? id,
    String? title,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    String? overview,
    List<String>? genres,
    String? originalLanguage,
    int? runtime,
    List<Actor>? actors,
    bool? isFavorite,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      overview: overview ?? this.overview,
      genres: genres ?? this.genres,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      runtime: runtime ?? this.runtime,
      actors: actors ?? this.actors,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'overview': overview,
      'genres': genres, // 직접 문자열 리스트 저장
      'original_language': originalLanguage,
      'runtime': runtime,
      'actors': actors.map((actor) => actor.toJson()).toList(),
      'is_favorite': isFavorite,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<Actor> actorsList = [];
    if (json['actors'] != null) {
      actorsList = (json['actors'] as List)
          .map((actorJson) => Actor.fromJson(actorJson))
          .toList();
    }

    // genres가 객체 리스트인 경우 (API 응답)
    List<String> genres = [];
    if (json['genres'] is List &&
        json['genres'].isNotEmpty &&
        json['genres'][0] is String) {
      genres = List<String>.from(json['genres']);
    } else if (json['genres'] != null) {
      genres = (json['genres'] as List)
          .map((genre) => genre['name'] as String)
          .toList();
    } else if (json['genre_ids'] != null) {
      genres = _getGenresFromIds(json['genre_ids'] as List);
    }

    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      voteAverage: json['vote_average']?.toDouble(),
      voteCount: json['vote_count'],
      overview: json['overview'],
      genres: genres,
      originalLanguage: json['original_language'],
      runtime: json['runtime'],
      actors: actorsList,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  // 장르 ID를 장르 이름으로 변환하는 매핑
  static List<String> _getGenresFromIds(List genreIds) {
    final Map<int, String> genreMap = {
      28: '액션',
      12: '모험',
      16: '애니메이션',
      35: '코미디',
      80: '범죄',
      99: '다큐멘터리',
      18: '드라마',
      10751: '가족',
      14: '판타지',
      36: '역사',
      27: '공포',
      10402: '음악',
      9648: '미스터리',
      10749: '로맨스',
      878: 'SF',
      10770: 'TV 영화',
      53: '스릴러',
      10752: '전쟁',
      37: '서부',
    };

    return genreIds.map((id) => genreMap[id] ?? '기타').toList();
  }

  // 포스터 이미지 URL 생성
  String get fullPosterPath => _getImageUrl(posterPath, 'w500');
  String get thumbnailPath => _getImageUrl(posterPath, 'w92');
  String get backdropImagePath => _getImageUrl(backdropPath, 'original');

  // 내부 헬퍼 메서드: 이미지 URL 생성
  String _getImageUrl(String? path, String size) {
    if (path == null || path.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  // 개봉일 포맷팅
  String get formattedReleaseDate {
    if (releaseDate == null || releaseDate!.isEmpty) return '미정';
    try {
      final date = DateTime.parse(releaseDate!);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return releaseDate!;
    }
  }

  // 개봉 연도만 반환
  String get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    try {
      return releaseDate!.substring(0, 4);
    } catch (e) {
      return '';
    }
  }

  // 평점 포맷팅
  String get formattedVoteAverage {
    if (voteAverage == null) return '평가없음';
    return voteAverage!.toStringAsFixed(1);
  }

  // 러닝타임 포맷팅
  String get formattedRuntime {
    if (runtime == null || runtime == 0) return '미정';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }

  // 장르 문자열 반환
  String get genresText {
    if (genres.isEmpty) return '장르 미정';
    return genres.join(' · ');
  }

  // 언어 코드를 한글로 변환
  String get languageText {
    switch (originalLanguage) {
      case 'ko':
        return '한국어';
      case 'en':
        return '영어';
      case 'ja':
        return '일본어';
      case 'zh':
        return '중국어';
      default:
        return originalLanguage ?? '알 수 없음';
    }
  }

  // 평가 참여 수 포맷팅
  String get formattedVoteCount {
    if (voteCount == null || voteCount == 0) return '평가 없음';
    if (voteCount! >= 1000) {
      return '${(voteCount! / 1000).toStringAsFixed(1)}k개의 평가';
    }
    return '$voteCount개의 평가';
  }

  // 검색이나 필터링을 위한 메서드
  bool matchesSearchTerm(String searchTerm) {
    final term = searchTerm.toLowerCase();
    return title.toLowerCase().contains(term) ||
        (overview?.toLowerCase().contains(term) ?? false);
  }
}

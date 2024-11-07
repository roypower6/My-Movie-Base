class Actor {
  final int id;
  final String name;
  final String? profilePath;
  final String character;

  Actor({
    required this.id,
    required this.name,
    this.profilePath,
    required this.character,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      character: json['character'] ?? '',
    );
  }

  String get fullProfilePath {
    if (profilePath == null || profilePath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_path': profilePath,
      'character': character,
    };
  }
}

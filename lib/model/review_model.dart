import 'package:flutter/foundation.dart';

class Review {
  final String id;
  final String author;
  final String content;
  final DateTime? createdAt;
  final double? rating;

  Review({
    required this.id,
    required this.author,
    required this.content,
    this.createdAt,
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Parsing review JSON: $json');
    }
    return Review(
      id: json['id'].toString(),
      author: json['author'] ?? json['username'] ?? '익명',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      rating: json['author_details'] != null &&
              json['author_details']['rating'] != null
          ? (json['author_details']['rating'] as num).toDouble()
          : null,
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.year}년 ${createdAt!.month}월 ${createdAt!.day}일';
  }

  String get formattedRating {
    if (rating == null) return '평가없음';
    return rating!.toStringAsFixed(1);
  }
}

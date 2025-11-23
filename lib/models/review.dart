import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });

  // Convert from Firestore Data
  factory Review.fromMap(String id, Map<String, dynamic> map) {
    
    // 🛡️ ROBUST DATE PARSER
    // Handles String, Timestamp, or Null safely
    DateTime parseDate(dynamic input) {
      if (input is Timestamp) {
        return input.toDate();
      } else if (input is String) {
        return DateTime.tryParse(input) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Review(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      comment: map['comment'] ?? '',
      // Handle int vs double safely
      rating: (map['rating'] is int) 
          ? (map['rating'] as int).toDouble() 
          : (map['rating'] ?? 0.0).toDouble(),
      date: parseDate(map['date']),
    );
  }

  // Convert to Firestore Data
  Map<String, dynamic> toMap({bool forLocalStorage = false}) {
    return {
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      // IMPROVEMENT: If saving to local storage, store actual date. 
      // If sending to Firebase, use ServerTimestamp for accuracy.
      'date': forLocalStorage 
          ? date.toIso8601String() 
          : FieldValue.serverTimestamp(),
    };
  }

  // FEATURE: copyWith
  // Essential for "Edit Review" functionality
  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? comment,
    double? rating,
    DateTime? date,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      date: date ?? this.date,
    );
  }

  // FEATURE: UI Helper for "Time Ago"
  // Usage: Text(review.timeAgo) -> "2 hours ago"
  String get timeAgo {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()} years ago";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()} months ago";
    if (diff.inDays > 0) return "${diff.inDays} days ago";
    if (diff.inHours > 0) return "${diff.inHours} hours ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} mins ago";
    return "Just now";
  }

  @override
  String toString() {
    return 'Review(id: $id, user: $userName, rating: $rating)';
  }
}
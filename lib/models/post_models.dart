import 'package:cloud_firestore/cloud_firestore.dart';
class PostModel {
  String userId;
  String postId;
  String content;
  String follow;
  List<LikeModel> likes; // List of LikeModel
  List<String> shares; // Assuming shares are user IDs who shared the post
  List<CommentModel> comments; // List of CommentModel
  DateTime? timestamp;

  PostModel({
    required this.userId,
    required this.content,
    required this.postId,
    this.follow = 'Empty',
    this.likes = const [],
    this.shares = const [],
    this.comments = const [],
    this.timestamp,
  });

  // Convert PostModel to a map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'postId': postId,
      'follow': follow,
      'likes': likes.map((like) => like.toMap()).toList(),
      'shares': shares, // assuming shares are userIds
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }

  // Factory constructor to create a PostModel from a map (for retrieving from Firestore)
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      userId: map['userId'] ?? 'unknown',
      content: map['content'] ?? '',
      postId: map['postId'] ?? '',
      follow: map['follow'] ?? 'Empty',
      likes: List<LikeModel>.from(map['likes']?.map((item) => LikeModel.fromMap(item)) ?? []),
      shares: List<String>.from(map['shares'] ?? []),
      comments: List<CommentModel>.from(map['comments']?.map((item) => CommentModel.fromMap(item)) ?? []),
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : null,
    );
  }
}
class LikeModel {
  String docRef;
  String userId;
  bool like;

  LikeModel({
    required this.docRef,
    required this.userId,
    required this.like,
  });

  // Convert LikeModel to a map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'docRef': docRef,
      'userId': userId,
      'like': like,
    };
  }

  // Factory constructor to create LikeModel from a map (for retrieving from Firestore)
  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      docRef: map['docRef'] ?? '',
      userId: map['userId'] ?? '',
      like: map['like'] ?? false,
    );
  }
}
class CommentModel {
  String docRef;
  String userId;
  String comment;
  DateTime? timestamp;

  CommentModel({
    required this.docRef,
    required this.userId,
    required this.comment,
    this.timestamp,
  });

  // Convert CommentModel to a map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'docRef': docRef,
      'userId': userId,
      'comment': comment,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }

  // Factory constructor to create CommentModel from a map (for retrieving from Firestore)
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      docRef: map['docRef'] ?? '',
      userId: map['userId'] ?? '',
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : null,
    );
  }
}


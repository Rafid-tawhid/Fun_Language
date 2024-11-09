import 'package:cloud_firestore/cloud_firestore.dart';
class PostModel {
  String userId;
  String postId;
  String content;
  String follow;
  String username;
  String like;
  String share; // Assuming shares are user IDs who shared the post
  String comment; // List of CommentModel
  DateTime? timestamp;
  List<String>? imageUrls;
  bool isLikedAlready;

  PostModel({
    required this.userId,
    required this.content,
    required this.postId,
    required this.username,
    this.follow = 'Empty',
    this.like = '0',
    this.share = '0',
    this.comment = '0',
    this.timestamp,
    this.imageUrls,
    this.isLikedAlready=false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'postId': postId,
      'follow': follow,
      'username': username,
      'like': like,
      'share': share, // assuming shares are userIds
      'comment': comment,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'imageUrls': imageUrls,
    };
  }

  // Factory constructor to create a PostModel from a map (for retrieving from Firestore)
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      userId: map['userId'] ?? 'unknown',
      content: map['content'] ?? '',
      postId: map['postId'] ?? '',
      follow: map['follow'] ?? 'Empty',
      username: map['username'] ?? 'No name',
      like: map['like'] ?? '0',
      share: map['share'] ?? '0',
      comment: map['comment'] ?? '0',
      timestamp: map['timestamp'] != null ? (map['timestamp'] as Timestamp).toDate() : null,
      imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null, // Cast the list explicitly
      isLikedAlready: map['isLikedAlready']??false, // Cast the list explicitly
    );
  }

   PostModel updatePostModel(PostModel post, Map<String, dynamic> updatedData) {
    // Update the fields in the PostModel based on the map
    if (updatedData.containsKey('content')) {
      post.content = updatedData['content'];
    }
    if (updatedData.containsKey('follow')) {
      post.follow = updatedData['follow'];
    }
    if (updatedData.containsKey('like')) {
      post.like = updatedData['like'];
    }
    if (updatedData.containsKey('share')) {
      post.share = updatedData['share'];
    }
    if (updatedData.containsKey('comment')) {
      post.comment = updatedData['comment'];
    }
    if (updatedData.containsKey('timestamp')) {
      post.timestamp = updatedData['timestamp'];
    }
    if (updatedData.containsKey('isLikedAlready')) {
      post.isLikedAlready = updatedData['isLikedAlready'];
    }

    // Return the updated PostModel
    return post;
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


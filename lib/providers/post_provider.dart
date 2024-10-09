import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/post_models.dart';

class PostProvider extends ChangeNotifier{
  List<PostModel> postModelList=[];
  List<LikeModel> likeList=[];

  Future<void> saveLikeInfo({
    required String id,
    required String userId,
    bool like = false,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Add a like to the subcollection 'likes' under the specific post
      DocumentReference documentReference = _firestore.collection('posts').doc(id).collection('likes').doc();
      await documentReference.set({
        "docRef": documentReference.id,
        "userId": userId,
        "like": like
      });

      // Fetch the current like count of the post
      var getLikesCount = await _firestore.collection('posts').doc(id).get();
      int likes = int.parse(getLikesCount['like']) + 1;

      // Update the like count in Firestore
      await _firestore.collection('posts').doc(id).update({'like': '$likes'});

      // Update the like count in the postModelList
      postModelList = postModelList.map((post) {
        if (post.postId == id) {
          return post.updatePostModel(post, {'like': likes.toString()});
        }
        return post;
      }).toList();

      notifyListeners();

    } catch (e) {
      // Handle errors
      print('Error uploading like info: $e');
    }
  }




  Future<void> createPost({
    required String content,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;

    try {
      // Create a document reference with a custom postId
      DocumentReference documentReference = _firestore.collection('posts').doc();

      // Create a PostModel with the custom postId
      PostModel post = PostModel(
        userId: currentUser?.uid ?? 'unknown', // Ensure userId is set correctly
        content: content,
        postId: documentReference.id, // Assign the generated ID as postId
        timestamp: DateTime.now(),
      );

      // Set the post data to the specific document reference
      await documentReference.set(post.toMap()); // Use set() to use the custom document ID

      // Notify listeners to refresh UI if needed
      notifyListeners();
    } catch (e) {
      // Handle errors
      print('Error creating post: $e');
    }
  }



  Future<void> getPost() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      // Get the post document from Firestore
      var postSnapshot = await _firestore.collection('posts').get();
      postModelList.clear();
      likeList.clear();
      if (postSnapshot.docs.isNotEmpty) {

        for(var i in postSnapshot.docs){
          postModelList.add(PostModel.fromMap(i.data()));
        }
        var likes=await _firestore.collection('posts').get();

        for(var i in likes.docs){
         // likeList.add(LikeModel.fromMap(i.data()['likes']));
         var data= await _firestore.collection('posts').doc(i.id).collection('likes').get();
          // likeList.add(LikeModel.fromMap(data.docs));
         List<LikeModel> postsLikes = data.docs.map((doc) {
           return LikeModel.fromMap(doc.data());
         }).toList();
         likeList.addAll(postsLikes);
        }
        debugPrint('postModelList ${postModelList.length}');
        debugPrint('likeList ${likeList.length}');
        notifyListeners();
        // Return the PostModel
      } else {
        print('Post not found');
        return null;
      }
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }


}
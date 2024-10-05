import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_messenger/models/user_model.dart';

import '../models/post_models.dart';

class PostProvider extends ChangeNotifier{
  Future<void> saveLikeInfo({
    required String id,
    required String userId,
    bool like = false,
    String comment = '',
    int share = 0,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {

      // var data= await _firestore.collection('posts').doc(id).get();
      DocumentReference documentReference=_firestore.collection('posts').doc(id).collection('likes').doc();
      documentReference.set({
        "docRef":documentReference.id,
        "userId":userId,
        "like":like
      });

    } catch (e) {
      // Handle errors
      print('Error uploading post: $e');
    }
  }

  // Function to get a like by document ID
  Future<String> getLike(String postId,String userId) async {

    String text='like';
    List<Map<String, dynamic>> likesList = [];

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {

      QuerySnapshot snapshot = await _firestore.collection('posts').doc(postId).collection('likes').get();

      // Iterate through each document in the snapshot
      for (var doc in snapshot.docs) {
        // Add each document's data to the likesList
        likesList.add(doc.data() as Map<String, dynamic>);
      }
      for (var data in likesList){
        if(data['userId']==userId){
          debugPrint('found ${data['like']}');
          text='liked';
        }
        else {
          text='like';
        }
      }
        print('Retrieved ${likesList.length} likes for postId: $postId');
    } catch (e) {
      print('Error getting likes: $e');
      text='like';
    }

    return text;
  }



  Future<void> createPost({
    required String content,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;

    try {
      // Create a PostModel
      PostModel post = PostModel(
        userId: currentUser?.uid ?? 'unknown', // Ensure userId is set correctly
        content: content,
        timestamp: DateTime.now(), // Local timestamp, you can also rely on Firestore's serverTimestamp
      );

      // Add the post to Firestore (convert to map before saving)
      await _firestore.collection('posts').add(post.toMap());

      // Notify listeners to refresh UI if needed
      notifyListeners();
    } catch (e) {
      // Handle errors
      print('Error creating post: $e');
    }
  }


  Future<PostModel?> getPost(String postId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Get the post document from Firestore
      DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(postId).get();

      if (postSnapshot.exists) {
        // Convert the document data into a PostModel
        Map<String, dynamic> data = postSnapshot.data() as Map<String, dynamic>;
        PostModel post = PostModel.fromMap(data);

        // Return the PostModel
        return post;
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
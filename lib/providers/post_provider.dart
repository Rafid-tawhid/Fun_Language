import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_messenger/models/user_model.dart';

import '../models/post_models.dart';

class PostProvider extends ChangeNotifier{
  List<PostModel> postModelList=[];
  List<LikeModel> likeList=[];
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
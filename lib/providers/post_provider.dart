import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/src/types/interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_messenger/models/user_model.dart';
import '../models/post_models.dart';
import 'package:image_picker/image_picker.dart';


class PostProvider extends ChangeNotifier{
  List<PostModel> postModelList=[];
  List<LikeModel> likeList=[];
  List<File> uploadImageList=[];

  Future<void> saveLikeInfo({
    required String id,
    required String userId,
    bool like = false,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {

      int? likes;

      QuerySnapshot allLikesOfThatPost=await _firestore.collection('posts').doc(id).collection('likes').where('userId',isEqualTo: userId).get();
     if(allLikesOfThatPost.docs.length>0){
       QuerySnapshot querySnapshot = await _firestore
           .collection('posts')
           .doc(id)
           .collection('likes')
           .where('userId', isEqualTo: userId)
           .get();

// Loop through the documents and delete each one from the correct path
       for (QueryDocumentSnapshot doc in querySnapshot.docs) {
         await _firestore
             .collection('posts')
             .doc(id)
             .collection('likes')
             .doc(doc.id)
             .delete();  // Ensure you're deleting from the same collection where you're querying from
         debugPrint('Deleted document with ID: ${doc.id}');
       }

       var getLikesCount = await _firestore.collection('posts').doc(id).get();
      likes = int.parse(getLikesCount['like']) - 1;
     }
     else {
       DocumentReference docRef=_firestore.collection('posts').doc(id).collection('likes').doc();
       docRef.set(LikeModel(docRef: docRef.id, userId: userId??'', like: true).toMap());
       var getLikesCount = await _firestore.collection('posts').doc(id).get();
       likes = int.parse(getLikesCount['like']) + 1;
     }
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
        username: UserModel.name??'No name',
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

  void saveToImageList(File pickedFile) {
    uploadImageList.add(pickedFile);
    notifyListeners();
  }

  void clearImageList({int? index}){
    if(index!=null){
      uploadImageList.remove(index);
    }
    else {
      uploadImageList.clear();
    }
    notifyListeners();
  }


}
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/src/types/interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_messenger/models/user_model.dart';
import '../models/post_models.dart';
import 'package:image_picker/image_picker.dart';


class PostProvider extends ChangeNotifier{
  List<PostModel> postModelList=[];
  List<LikeModel> likeList=[];
  List<File> uploadImageList=[];
  bool isLoading=false;
  bool showLoadingPost=false;

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
      _firestore.collection('posts').doc(id).collection('likes').where('userId',isEqualTo: userId).limit(1);

    } catch (e) {
      // Handle errors
      print('Error uploading like info: $e');
    }
  }




  Future<void> createPost({
    required String content, // List of image files
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    List<String> imageUrls = [];

    try {
      // Upload images and get their download URLs

      setLoading(true);
      if(uploadImageList.isNotEmpty){
        for (File imageFile in uploadImageList) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique file name
          Reference ref = _storage.ref().child('posts/${currentUser?.uid}/$fileName');
          // Upload the image file
          UploadTask uploadTask = ref.putFile(imageFile);
          TaskSnapshot taskSnapshot = await uploadTask;
          // Get the download URL
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl); // Add the URL to the list
        }
      }

      // Create a document reference with a custom postId
      DocumentReference documentReference = _firestore.collection('posts').doc();

      // Create a PostModel with the custom postId
      PostModel post = PostModel(
        userId: currentUser?.uid ?? 'unknown', // Ensure userId is set correctly
        content: content,
        username: UserModel.name ?? 'No name',
        postId: documentReference.id, // Assign the generated ID as postId
        timestamp: DateTime.now(),
        imageUrls: imageUrls, // Add the list of image URLs
      );

      // Set the post data to the specific document reference
      await documentReference.set(post.toMap());

      //add data to list first

      postModelList.insert(0,post);

      // Notify listeners to refresh UI if needed

    } catch (e) {
      // Handle errors
      print('Error creating post: $e');
    }
    finally {
      setLoading(false);
    }
  }


  // Future<bool> isLikedAlready(userId){
  //
  //   FirebaseFirestore _firestore;
  //   _firestore.collection(collectionPath)
  // }




  Future<void> getPost() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      // Get the post document from Firestore
      showLoading(true);
      var postSnapshot = await _firestore.collection('posts').orderBy('timestamp', descending: true).get();

      showLoading(false);
      postModelList.clear();
      likeList.clear();
      if (postSnapshot.docs.isNotEmpty) {
        for(var i in postSnapshot.docs){
          final List<LikeModel> likes= await getLikeListOfThiDocument(i.id);

          postModelList.add(PostModel.fromMap(i.data()));
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


  //Future<void> getPost() async {
  //     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //     try {
  //       // Get the post document from Firestore
  //       showLoading(true);
  //       var postSnapshot = await _firestore.collection('posts').orderBy('timestamp', descending: true).get();
  //
  //       showLoading(false);
  //       postModelList.clear();
  //       likeList.clear();
  //       if (postSnapshot.docs.isNotEmpty) {
  //
  //         for(var i in postSnapshot.docs){
  //           var isLiked= await _firestore.collection('posts').doc(i.id).collection('likes').where('userId',isEqualTo: FirebaseAuth.instance.currentUser!.uid).limit(1).get();
  //           bool isLikedPost=isLiked.docs.isNotEmpty?true:false;
  //           PostModel postModel=PostModel.fromMap(i.data());
  //           postModelList.add(postModel);
  //           postModel.updatePostModel(postModel, {'isLikedAlready': isLikedPost});
  //           debugPrint('postModelList ${postModel.toMap()}');
  //         }
  //         notifyListeners();
  //         // Return the PostModel
  //       } else {
  //         print('Post not found');
  //         return null;
  //       }
  //     } catch (e) {
  //       print('Error getting post: $e');
  //       return null;
  //     }
  //   }
  void showLoading(bool load){
    showLoadingPost=load;
    notifyListeners();
  }

  void saveToImageList(File pickedFile) {
    uploadImageList.add(pickedFile);
    notifyListeners();
  }

  void clearImageList({int? index}){
    debugPrint('index ${index}');
    if(index!=null){
      uploadImageList.removeAt(index);
    }
    else {
      uploadImageList.clear();
    }
    debugPrint('clearImageList ${uploadImageList.length}');
    notifyListeners();
  }

  void setLoading(bool bool) {
    isLoading=bool;
    notifyListeners();
  }



}
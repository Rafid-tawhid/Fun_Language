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
  List<File> uploadImageList=[];
  bool isLoading=false;
  bool showLoadingPost=false;

  Future<void> saveLikeInfo({
    required String id,
    required String userId,
    required PostModel postItem,
    bool like = false,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Check if user has already liked the post
      final userLikeDocs = await _firestore
          .collection('posts')
          .doc(id)
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .get();

      // If like exists, remove it; otherwise, add a new like
      int updatedLikes;
      if (userLikeDocs.docs.isNotEmpty) {
        // Remove like from Firestore
        for (var doc in userLikeDocs.docs) {
          await _firestore.collection('posts').doc(id).collection('likes').doc(doc.id).delete();
        }

        // Update local post data
        postModelList = postModelList.map((post) {
          if (post.postId == postItem.postId) {
            return post.updateLikeList(postItem, userLikeDocs.docs.first.id, false);
          }
          return post;
        }).toList();

        // Decrement like count
        final postSnapshot = await _firestore.collection('posts').doc(id).get();
        updatedLikes = (int.parse(postSnapshot['like']) - 1);
      } else {
        // Add new like to Firestore
        final newLikeRef = _firestore.collection('posts').doc(id).collection('likes').doc();
        await newLikeRef.set(LikeModel(docRef: newLikeRef.id, userId: userId, like: true).toMap());

        // Update local post data
        postModelList = postModelList.map((post) {
          if (post.postId == postItem.postId) {
            return post.updateLikeList(postItem, newLikeRef.id, true);
          }
          return post;
        }).toList();

        // Increment like count
        final postSnapshot = await _firestore.collection('posts').doc(id).get();
        updatedLikes = (int.parse(postSnapshot['like']) + 1);
      }

      // Update like count in Firestore and locally
      await _firestore.collection('posts').doc(id).update({'like': '$updatedLikes'});
      postModelList = postModelList.map((post) {
        if (post.postId == id) {
          return post.updatePostModel(post, {'like': updatedLikes.toString()});
        }
        return post;
      }).toList();

      notifyListeners();
    } catch (e) {
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
      postModelList.clear();

      var postSnapshot = await _firestore.collection('posts').orderBy('timestamp', descending: true).get();

      if (postSnapshot.docs.isNotEmpty) {
        for(var i in postSnapshot.docs){
          final List<LikeModel> likes= await getLikeListOfThiDocument(i.reference);
          postModelList.add(PostModel.fromMap(i.data(),likes: likes));
        }

        debugPrint('postModelList ${postModelList.length}');

        showLoading(false);
      } else {
        print('Post not found');
        return null;
      }
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }

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

  Future<List<LikeModel>> getLikeListOfThiDocument(DocumentReference postRef) async {
    try {
      final likeSnapshot = await postRef.collection('likes').get();
      return likeSnapshot.docs.map((doc) => LikeModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting likes: $e');
      return [];
    }
  }

  void updateModel(PostModel postData) {
    // Find the post in the list with matching postId
    var data = postModelList.firstWhere((e) => e.postId == postData.postId);

    // Check if the current user's like already exists in the likeList
    final currentUserLikeIndex = data.likeList!.indexWhere(
          (e) => e.userId == postData.userId,
    );

    if (currentUserLikeIndex != -1) {
      // If it exists, remove the like (unlike)
      debugPrint('debugprint remove');
      data.likeList!.removeAt(currentUserLikeIndex);
    } else {
      // If it does not exist, add a new like
      data.likeList!.add(
        LikeModel(
          docRef: postData.postId,
          userId: FirebaseAuth.instance.currentUser!.uid,
          like: true,
        ),
      );
      debugPrint('debugprint added');
    }

    notifyListeners();
  }




// for(var i in likes.docs){
//  // likeList.add(LikeModel.fromMap(i.data()['likes']));
//  var data= await _firestore.collection('posts').doc(i.id).collection('likes').get();
//  List<LikeModel> postsLikes = data.docs.map((doc) {
//    return LikeModel.fromMap(doc.data());
//  }).toList();
// likeList.addAll(postsLikes);
// }

}
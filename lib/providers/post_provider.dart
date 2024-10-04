import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

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

      var data= await _firestore.collection('posts').doc(id).get();
      await _firestore.collection('posts').doc(id).update({
        'newKey': 'newValue':{"a":"dd"},  // This will add 'newField': 'newValue' to the document
      });


    } catch (e) {
      // Handle errors
      print('Error uploading post: $e');
    }
  }

  Future<int> getReactions(String lable, String postId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    int totalLikes = 0;

    try {
     if(lable=='Like'){
       // Query the 'reactions' collection for the specific postId where 'likes' is true
       QuerySnapshot snapshot = await _firestore
           .collection('reactions')
           .where('postId', isEqualTo: postId)
           .where('likes', isEqualTo: true)
           .get();

       // The total number of likes is the number of documents that match the query
       totalLikes = snapshot.size;

       print('Total likes for postId $postId: $totalLikes');
     }
    } catch (e) {
      // Handle errors
      print('Error retrieving likes: $e');
    }

    return totalLikes;
  }





}
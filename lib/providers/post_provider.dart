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
      // Generate a new unique reference (for the new collection)
      String uniqueKey = _firestore.collection('posts').doc().id;  // Unique key for the new document in the 'like' collection

// Prepare the value map you want to associate with the document in the 'like' collection
      Map<String, dynamic> valueMap = {
        'field1': uniqueKey,
        'field2': 'value2',
        'field3': 'value3',
      };


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
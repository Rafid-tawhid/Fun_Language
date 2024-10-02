import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class PostProvider extends ChangeNotifier{
  Future<void> saveReaction({
    required String id,
    required String userId,
    bool like = false,
    String comment = '',
    int share = 0,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Create a new document reference with an auto-generated ID
      DocumentReference docRef = _firestore.collection('reactions').doc();
      String docId = docRef.id; // Get the generated document ID

      // Add the document data along with the docId
      await docRef.set({
        'postId': id,
        'userId': userId,
        'docId': docId, // Include the generated docId
        'likes': like,
        'shares': share,
        'comments': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Data saved successfully with docId: $docId');

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
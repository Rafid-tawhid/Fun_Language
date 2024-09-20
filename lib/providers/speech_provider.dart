import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpeechProvider extends ChangeNotifier{

  List<dynamic> speakingPracList=[];
  bool isLoading=false;
  List<bool> isPlayingList=[];

  Future<void> getSpeechPractices() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('practices')
            .doc(currentUser.uid)
            .collection('speaking')
            .get();
        speakingPracList.clear();

        final practices = querySnapshot.docs.map((doc) => doc.data()).toList();
        speakingPracList.addAll(practices);
        isPlayingList = List.filled(speakingPracList.length, false);
        // Now 'practices' contains all the speech practices for the current user
        // Do whatever you want with 'practices', for example, print them
        print('Speech Practices for user ${currentUser.uid}: $practices');
        print('speakingPracList ${speakingPracList.length}');
      } else {
        print('User not logged in!');
      }
    } catch (error) {
      print('Error getting speech practices: $error');
    }
    notifyListeners();
  }

  setIsLoading(bool val){
    isLoading=val;
    notifyListeners();
  }

  void setLoadingIndex(int index) {
    // Set all values in the list to false
    for (int i = 0; i < isPlayingList.length; i++) {
      isPlayingList[i] = false;
    }

    // Toggle only the value at the specified index
    isPlayingList[index] = !isPlayingList[index];

    // Notify listeners to update the UI
    notifyListeners();
  }


}
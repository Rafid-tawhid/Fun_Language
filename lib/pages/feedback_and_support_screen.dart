import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedbackAndSupportScreen extends StatefulWidget {
  const FeedbackAndSupportScreen({super.key});

  @override
  State<FeedbackAndSupportScreen> createState() => _FeedbackAndSupportScreenState();
}

class _FeedbackAndSupportScreenState extends State<FeedbackAndSupportScreen> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendFeedback(double rating, String comment) async {
    try {
      User? user = _auth.currentUser; // Get the current user

      if (user != null) {
        // Feedback data to be sent
        Map<String, dynamic> feedbackData = {
          'userId': user.uid,
          'userEmail': user.email,
          'userName': user.displayName ?? "Anonymous",
          'rating': rating,
          'comment': comment,
          'submittedAt': Timestamp.now(),
        };

        // Add feedback to Firestore collection
        await _firestore.collection('feedback').add(feedbackData).then((v){
          _showSnackbar("Feedback submitted successfully.");
        });
        print("Feedback submitted successfully.");
      } else {
        print("No user is logged in.");
      }
    } catch (e) {
      print("Error submitting feedback: $e");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Feedback',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.purple,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(
          Icons.arrow_back,   // Using arrow_back as an example
          color: Colors.white,  // Change the color to red
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'We value your feedback!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Text(
              'Please rate your experience:',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Additional Comments',
                hintText: 'Enter your feedback here...',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: ()async{
                sendFeedback(_rating,_commentController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Submit',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}

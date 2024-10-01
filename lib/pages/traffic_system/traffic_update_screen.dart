import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrafficUpdateScreen extends StatefulWidget {
  const TrafficUpdateScreen({super.key});

  @override
  State<TrafficUpdateScreen> createState() => _TrafficUpdateScreenState();
}

class _TrafficUpdateScreenState extends State<TrafficUpdateScreen> {
  FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _postController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _postController.dispose();
    // Clean up the focus node when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create Post'),
        surfaceTintColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _postController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: "Share your thoughts...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (_isFocused)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _uploadPost,
                    icon: Icon(Icons.send),
                    label: Text('Post'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to upload post to Firebase
  Future<void> _uploadPost() async {
    String content = _postController.text.trim();
    if (content.isNotEmpty) {
      try {
        User? currentUser = _auth.currentUser;

        // Post data
        await _firestore.collection('posts').add({
          'userId': currentUser?.uid ?? 'unknown', // Handle user ID
          'content': content,
          'follow': 'Empty',
          'likes': 0, // Initialize with 0 likes
          'shares': 0, // Initialize with 0 shares
          'comments': [], // Empty comment list for now
          'timestamp': FieldValue.serverTimestamp(), // Firebase server timestamp
        });

        // Clear the text field after successful post
        _postController.clear();
        FocusScope.of(context).unfocus(); // Unfocus TextField after posting

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post uploaded successfully!')),
        );
      } catch (e) {
        // Handle errors
        print('Error uploading post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload post. Please try again.')),
        );
      }
    } else {
      // Show validation if content is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write something to post!')),
      );
    }
  }

}

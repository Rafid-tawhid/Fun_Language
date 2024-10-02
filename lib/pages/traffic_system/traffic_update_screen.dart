import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      child: Image.network(UserModel.image??'https://cdn.vectorstock.com/i/preview-1x/17/61/male-avatar-profile-picture-vector-10211761.jpg',height: 60,width: 60,fit: BoxFit.cover,),
                      borderRadius: BorderRadius.circular(50.0),

                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _postController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "What's on your mind?...",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (_isFocused)Align(
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
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {


                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator()); // Loading indicator while fetching data
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No posts available'));
                    }

                    // Get the list of posts from Firestore
                    var posts = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: posts.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        // Extract post data
                        var postData = posts[index].data() as Map<String, dynamic>;

                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile section with user name and time
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   if(postData['userId']!=null) FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance.collection('users').doc(postData['userId']).get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          // While the data is loading, show a loading indicator
                                          return Row(
                                            children: [
                                              CircularProgressIndicator(), // Show loading indicator
                                              SizedBox(width: 8), // Space between loading indicator and text
                                              Text(
                                                'No username', // Dummy name while loading
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          );
                                        } else if (snapshot.hasError) {
                                          // Handle any errors that might occur
                                          return Text(
                                            'Error: ${snapshot.error}',
                                            style: TextStyle(color: Colors.red),
                                          );
                                        } else if (snapshot.hasData && snapshot.data != null) {
                                          // When the data is successfully fetched, display the username
                                          return Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(50.0), // Circular image
                                                child: Image.network(snapshot.data!['image_url']??'https://cdn.vectorstock.com/i/preview-1x/17/61/male-avatar-profile-picture-vector-10211761.jpg',
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                    // Show an error icon or a placeholder if the image fails to load
                                                    return Icon(Icons.error, size: 60, color: Colors.red);
                                                  },
                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child; // Show the image once loaded
                                                    } else {
                                                      // Show a CircularProgressIndicator while the image is loading
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          value: loadingProgress.expectedTotalBytes != null
                                                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                              : null,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              // User name and post time
                                              Column(
                                                children: [
                                                  Text(
                                                    snapshot.data!['username']?.toString() ?? 'No username', // Use a fallback in case of null
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    formatTimestamp(postData['timestamp'])?? 'just now',
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                                ],
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                              ),
                                              Spacer(),
                                              // More options (three dots)
                                              Icon(Icons.more_horiz),

                                            ],
                                          );
                                        } else {
                                          // If no data is returned, show a default message
                                          return Text(
                                            'No user found',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),

                                // Post content
                                Text(
                                  postData['content'] ?? 'No content',
                                  style: TextStyle(fontSize: 16),
                                ),

                                // Optional media (image)
                                if (postData['imageUrl'] != null) ...[
                                  SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      postData['imageUrl'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                    ),
                                  ),
                                ],

                                SizedBox(height: 10),
                                Divider(),

                                // Like, Comment, Share Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildPostAction(Icons.thumb_up_alt_outlined, 'Like', postData['likes'] ?? 0,postData['userId'],(){
                                      debugPrint('Clicked Like');
                                    }),
                                    _buildPostAction(Icons.comment_outlined, 'Comment', postData['comments']?.length ?? 0,postData['userId'],(){
                                      debugPrint('Clicked Comment');
                                    }),
                                    _buildPostAction(Icons.share_outlined, 'Share', postData['shares'] ?? 0,postData['userId'],(){
                                      debugPrint('Clicked Share');
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );


  }
  String? formatTimestamp(Timestamp? timestamp) {
    // Convert the timestamp to a DateTime object
    if(timestamp!=null){
      DateTime dateTime = timestamp.toDate();

      // Format the DateTime object to a readable string
      // You can customize the format string as needed
      String? formattedDate = DateFormat('MMMM d, y, h:mm a').format(dateTime);
      return formattedDate;
    }
    else {
      return null;
    }



  }
  Widget _buildPostAction(IconData icon, String label, int count,String userId,VoidCallback onClick) {
    return InkWell(
      onTap: onClick,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 5),
          Text(
            '$label ($count)',
            style: TextStyle(color: Colors.grey),
          ),
        ],
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_messenger/main.dart';
import 'package:my_messenger/pages/traffic_system/widgets/image_picker.dart';
import 'package:my_messenger/providers/post_provider.dart';
import 'package:provider/provider.dart';

import '../../models/post_models.dart';
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
   getAllPost();
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
        actions: [
         // IconButton(onPressed: pp.getPost, icon: Icon(Icons.abc))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Consumer<PostProvider>(builder: (context,pp,_)=>SingleChildScrollView(
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
                    ImagePickerWidget()
                  ],
                ),
                SizedBox(height: 10),
                if (_isFocused)Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: createPost,
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
                ListView.builder(
                  itemCount: pp.postModelList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Extract post data
                    var postData = pp.postModelList[index];

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
                                Text(
                                  postData.username, // Dummy name while loading
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            // Post content
                            Text(
                              postData.content?? 'No content',
                              style: TextStyle(fontSize: 16),
                            ),

                            // Optional media (image)
                            SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                UserModel.image??'',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),


                            SizedBox(height: 10),
                            Divider(),

                            //Like, Comment, Share Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildPostAction(Icons.thumb_up_alt_outlined, 'Like',postData, postData.postId,(){
                                  debugPrint('Clicked Like');
                                  var pp=context.read<PostProvider>();
                                  pp.saveLikeInfo(id: postData.postId,userId:FirebaseAuth.instance.currentUser!.uid,like: true);
                                }),
                                _buildPostAction(Icons.comment_outlined, 'Comment',postData, postData.postId,(){
                                  debugPrint('Clicked Comment');
                                  var pp=context.read<PostProvider>();
                                  // pp.getPost(postsId,postData['userId']);
                                }),
                                _buildPostAction(Icons.share_outlined, 'Share',postData, postData.postId,(){
                                  debugPrint('Clicked Share');
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )



                // StreamBuilder<QuerySnapshot>(
                //   stream: pp.getPostStream(),
                //   builder: (context, snapshot) {
                //
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return Center(child: CircularProgressIndicator()); // Loading indicator while fetching data
                //     }
                //     if (snapshot.hasError) {
                //       return Center(child: Text('Error: ${snapshot.error}'));
                //     }
                //
                //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                //       return Center(child: Text('No posts available'));
                //     }
                //
                //     // Get the list of posts from Firestore
                //     var posts = snapshot.data!.docs;
                //
                //
                //     return ListView.builder(
                //       itemCount: posts.length,
                //       shrinkWrap: true,
                //       physics: NeverScrollableScrollPhysics(),
                //       itemBuilder: (context, index) {
                //         // Extract post data
                //         var postData = posts[index].data() as Map<String, dynamic>;
                //         var postsId=posts[index].id;
                //         var pp=context.watch<PostProvider>();
                //         return Card(
                //           color: Colors.white,
                //           margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //           elevation: 5,
                //           child: Padding(
                //             padding: const EdgeInsets.all(12.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 // Profile section with user name and time
                //                 Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: [
                //                    if(postData['userId']!=null) Text(
                //                      'No username', // Dummy name while loading
                //                      style: TextStyle(
                //                        fontWeight: FontWeight.bold,
                //                        fontSize: 16,
                //                      ),
                //                    ),
                //                   ],
                //                 ),
                //
                //                 SizedBox(height: 10),
                //
                //                 // Post content
                //                 Text(
                //                   postData['content'] ?? 'No content',
                //                   style: TextStyle(fontSize: 16),
                //                 ),
                //
                //                 // Optional media (image)
                //                 if (postData['imageUrl'] != null) ...[
                //                   SizedBox(height: 10),
                //                   ClipRRect(
                //                     borderRadius: BorderRadius.circular(10.0),
                //                     child: Image.network(
                //                       postData['imageUrl'],
                //                       fit: BoxFit.cover,
                //                       width: double.infinity,
                //                       height: 200,
                //                     ),
                //                   ),
                //                 ],
                //
                //                 SizedBox(height: 10),
                //                 Divider(),
                //
                //                 // Like, Comment, Share Row
                //                 Row(
                //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     _buildPostAction(Icons.thumb_up_alt_outlined, 'Like',postData, postsId,(){
                //                       debugPrint('Clicked Like');
                //                       var pp=context.read<PostProvider>();
                //                       pp.saveLikeInfo(id: postsId,userId:  postData['userId'],like: true);
                //                     }),
                //                     _buildPostAction(Icons.comment_outlined, 'Comment',postData, postsId,(){
                //                       debugPrint('Clicked Comment');
                //                       var pp=context.read<PostProvider>();
                //                       pp.getPost(postsId,postData['userId']);
                //                     }),
                //                     _buildPostAction(Icons.share_outlined, 'Share',postData, postsId,(){
                //                       debugPrint('Clicked Share');
                //                     }),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           ),
                //         );
                //       },
                //     );
                //   },
                // )
              ],
            ),
          )),
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
  Widget _buildPostAction(IconData icon, String label,PostModel data,String postId, VoidCallback onClick) {
    var pp=context.read<PostProvider>();
    return InkWell(
      onTap: onClick,
      child: Container(
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            SizedBox(width: 5),
            Text('${label}'+' (${data.like})')
          ],
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
          'likes': [], // Initialize with 0 likes
          'shares': [], // Initialize with 0 shares
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




  Future<void> createPost() async {
    var pp=context.read<PostProvider>();
    var content= _postController.text.trim();
    if(content.isNotEmpty){
      await pp.createPost(content: content);
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Posted successfully')));
    }
  }

  void getAllPost() {
    var pp=context.read<PostProvider>();
    pp.getPost();
  }
}

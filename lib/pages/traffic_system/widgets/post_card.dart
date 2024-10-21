import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_messenger/models/post_models.dart';
import 'package:provider/provider.dart';

import '../../../providers/post_provider.dart';

class PostCard extends StatelessWidget {
  final PostModel postData;


  PostCard(this.postData);

  @override
  Widget build(BuildContext context) {
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

            Visibility(
              visible: postData.imageUrls != null && postData.imageUrls!.isNotEmpty,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  postData.imageUrls?[0] ?? '',  // Use null-aware access
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),



            SizedBox(height: 10),
            Divider(),

            //Like, Comment, Share Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPostAction(Icons.thumb_up_alt_outlined, 'Like',postData, postData.postId,context, (){
                  debugPrint('Clicked Like');
                  var pp=context.read<PostProvider>();
                  pp.saveLikeInfo(id: postData.postId,userId:FirebaseAuth.instance.currentUser!.uid,like: true);
                }),
                _buildPostAction(Icons.comment_outlined, 'Comment',postData, postData.postId,context,(){
                  debugPrint('Clicked Comment');
                  var pp=context.read<PostProvider>();
                  // pp.getPost(postsId,postData['userId']);
                }),
                _buildPostAction(Icons.share_outlined, 'Share',postData, postData.postId,context,(){
                  debugPrint('Clicked Share');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPostAction(IconData icon, String label,PostModel data,String postId,BuildContext context, VoidCallback onClick,) {
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_messenger/models/post_models.dart';
import 'package:provider/provider.dart';

import '../../../providers/post_provider.dart';
import 'images_show.dart';

class PostCard extends StatefulWidget {
  final PostModel postData;


  PostCard(this.postData);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  bool showCommentBox=false;

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
                  widget.postData.username, // Dummy name while loading
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
              widget.postData.content?? 'No content',
              style: TextStyle(fontSize: 16),
            ),

            // Optional media (image)
            SizedBox(height: 10),

            PostImageWidget(imageUrls: widget.postData.imageUrls??[],),

            SizedBox(height: 10),
            Divider(),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap:(){
                      var pp=context.read<PostProvider>();
                      pp.saveLikeInfo(id: widget.postData.postId,userId:FirebaseAuth.instance.currentUser!.uid,like: true);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.thumb_up,color:widget.postData.likeList!.any((e)=>e.userId==FirebaseAuth.instance.currentUser!.uid)?Colors.blue: Colors.grey,),
                        SizedBox(width: 5),
                        Text('Like'+' (${widget.postData.likeList!.length})')
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap:(){
                      setState(() {
                        showCommentBox=!showCommentBox;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_outlined, color: Colors.grey),
                        SizedBox(width: 5),
                        Text('Comments')
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap:(){
                      var pp=context.read<PostProvider>();
                      pp.saveLikeInfo(id: widget.postData.postId,userId:FirebaseAuth.instance.currentUser!.uid,like: true);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.share_outlined, color: Colors.grey),
                        SizedBox(width: 5),
                        Text('Share'+' (${0})')
                      ],
                    ),
                  ),
                )
              ],
            ),
            if(showCommentBox)ChatInputField(onSend: () {  },)
          ],
        ),
      ),
    );
  }
}


class ChatInputField extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final VoidCallback onSend;

  ChatInputField({required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white, // background color
          borderRadius: BorderRadius.circular(12), // rounded borders
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // shadow direction
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Type a comment...",
                  border: InputBorder.none, // remove underline
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 8), // space between text field and icon
            GestureDetector(
              onTap: onSend, // trigger send action
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue, // background color of the send button
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white, // icon color
                  size: 16, // icon size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

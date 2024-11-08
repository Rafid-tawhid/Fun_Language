import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_messenger/main.dart';
import 'package:my_messenger/pages/traffic_system/widgets/image_picker.dart';
import 'package:my_messenger/pages/traffic_system/widgets/post_card.dart';
import 'package:my_messenger/providers/post_provider.dart';
import 'package:my_messenger/utils/temp_db.dart';
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
   Future.microtask((){
     getAllPost();
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
                      borderRadius: BorderRadius.circular(50.0),
                      child: UserModel.image != null && UserModel.image!.isNotEmpty
                          ? Image.network(
                        UserModel.image??'',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Display a placeholder image on error
                          return Image.asset(
                            'images/avater.gif', // Make sure this path is correct
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          : Image.asset(
                        'images/avater.gif', // Placeholder for null image URL
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
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

                Consumer<PostProvider>(
                  builder: (context,pp,_)=>Visibility(
                    visible: pp.uploadImageList.length>0,
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(
                              child: pp.uploadImageList.length>0?
                              ListView.builder(
                                itemCount: pp.uploadImageList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context,index)=>Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Stack(
                                    children: [
                                      Image.file(pp.uploadImageList[index],height: 60,width: 60,fit: BoxFit.cover,),
                                      Positioned(right: 0,top: 0,child: InkWell(
                                          onTap: (){
                                            pp.clearImageList(index: index);
                                          },
                                          child: Icon(Icons.close)),)
                                    ],
                                  ),
                                ),
                              ):SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_isFocused)Align(
                  alignment: Alignment.bottomRight,
                  child: Consumer<PostProvider>(
                    builder: (context,pro,_)=>ElevatedButton.icon(
                      onPressed: pro.isLoading?null:createPost,
                      icon: Icon(Icons.send),
                      label: pro.isLoading?Container(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(color: Colors.grey,)):Text('Post'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                pp.showLoadingPost?Center(child: CircularProgressIndicator(),):
                ListView.builder(
                  itemCount: pp.postModelList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Extract post data
                    var postData = pp.postModelList[index];
                    return PostCard(postData);
                  },
                )

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




  Future<void> createPost() async {
    var pp=context.read<PostProvider>();
    var content= _postController.text.trim();
    if(content.isNotEmpty){
      Future.microtask(() async {
        await pp.createPost(content: content);
        pp.clearImageList();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Posted successfully')));
      });


    }
  }

  void getAllPost() {
    var pp=context.read<PostProvider>();
    pp.getPost();
  }
}

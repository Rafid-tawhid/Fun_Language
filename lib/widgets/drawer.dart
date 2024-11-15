import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class MyDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Container(
        color: Colors.blue, // Set the background color to blue
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Set a slightly different shade of blue for the header
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(UserModel.image??'https://cdn.vectorstock.com/i/preview-1x/17/61/male-avatar-profile-picture-vector-10211761.jpg'),

                    // You can replace the image with the actual user profile image
                    // backgroundImage: NetworkImage('url_to_profile_image'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    UserModel.name?? 'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    UserModel.email?? 'john.doe@example.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to the home screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to the settings screen
                Navigator.pop(context);
                // Add your navigation logic here
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navigate to the settings screen
                FirebaseAuth.instance.signOut();
                // Add your navigation logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}
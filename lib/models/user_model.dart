import 'package:flutter/cupertino.dart';

class UserModel {
  static String? name;
  static String? email;
  static String? image;

  static setData(String nameP,String emailP,String imageP){
    name=nameP;
    email=emailP;
    image=imageP;

    debugPrint('----Set user info----');
    debugPrint(nameP);
    debugPrint(emailP);
    debugPrint(imageP);
  }
}
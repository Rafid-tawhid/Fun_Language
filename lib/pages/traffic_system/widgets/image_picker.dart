import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_messenger/providers/post_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  // Handle image selection from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    // Check permission
    if (source == ImageSource.camera) {
      if (await _requestCameraPermission()) {
        final pickedFile = await _picker.pickImage(source: source,imageQuality: 50,maxWidth: 150);

        if(pickedFile!=null){
          var pp=context.read<PostProvider>();
          pp.saveToImageList(File(pickedFile.path));
        }

      } else {
        // Handle camera permission denied
        _showPermissionDeniedMessage('Camera');
      }
    } else if (source == ImageSource.gallery) {
      if (await _requestGalleryPermission()) {
        final pickedFile= await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality: 50,maxWidth: 150);
        if(pickedFile!=null){
          var pp=context.read<PostProvider>();
          pp.saveToImageList(File(pickedFile.path));
        }
      } else {
        // Handle gallery permission denied
        _showPermissionDeniedMessage('Gallery');
      }
    }
  }

  // Request camera permission
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  // Request gallery permission
  Future<bool> _requestGalleryPermission() async {
    //var status = await Permission.photos.status;
    var status = await Permission.storage.request();
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    return true;
  }

  // Show alert to choose camera or gallery
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show permission denied message
  void _showPermissionDeniedMessage(String source) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text('$source permission is required to access the $source.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: (){
      _showImageSourceActionSheet(context);
    }, icon: Icon(Icons.image_outlined));
  }
}

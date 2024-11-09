import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostImageWidget extends StatelessWidget {
  final List<String>? imageUrls;

  PostImageWidget({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    int imageCount=0;
    if(imageUrls!=null){
     imageCount = imageUrls!.length;
    }
    else {
     imageCount=0;
    }


    return Visibility(
      visible: imageCount > 0,
      child: GestureDetector(
        onTap: (){
          if(imageCount>0){
            Navigator.push(context, CupertinoPageRoute(builder: (context)=>ImageViewSlider(imageUrls??[])));
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: buildImageLayout(imageCount),
        ),
      ),
    );
  }

  Widget buildImageLayout(int imageCount) {
    switch (imageCount) {
      case 0:
        return Text('data');
      case 1:
        return _buildSingleImage();
      case 2:
        return _buildTwoImages();
      case 3:
        return _buildThreeImages();
      default:
        return _buildMoreThanThreeImages();
    }
  }

  Widget _buildSingleImage() {
    return Image.network(
      imageUrls![0],
      fit: BoxFit.cover,
      width: double.infinity,
      height: 300,
    );
  }

  Widget _buildTwoImages() {
    return Row(
      children: [
        Expanded(
          child: Image.network(
            imageUrls![0],
            fit: BoxFit.cover,
            height: 200,
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Image.network(
            imageUrls![1],
            fit: BoxFit.cover,
            height: 200,
          ),
        ),
      ],
    );
  }

  Widget _buildThreeImages() {
    return Column(
      children: [
        Image.network(
          imageUrls![0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Image.network(
                imageUrls![1],
                fit: BoxFit.cover,
                height: 100,
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Image.network(
                imageUrls![2],
                fit: BoxFit.cover,
                height: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreThanThreeImages() {
    return Column(
      children: [
        Image.network(
          imageUrls![0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Image.network(
                imageUrls![1],
                fit: BoxFit.cover,
                height: 100,
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    imageUrls![2],
                    fit: BoxFit.cover,
                    height: 100,
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          '+${imageUrls!.length - 3}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class ImageViewSlider extends StatelessWidget {
  final List<String> imageUrls;


  ImageViewSlider(this.imageUrls);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(child: Center(
            child: Stack(
              children: [
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context,index)=>Image.network(
                      imageUrls[index],
                    width: MediaQuery.sizeOf(context).width,
                  ),
                ),
                Positioned(
                  child: IconButton(onPressed: (){
                    Navigator.pop(context);

                  }, icon: Icon(Icons.close,color: Colors.white,)),
                  right: 10,
                  top: 10,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

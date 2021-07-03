import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
  home: HomeScreen(),
));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  PickedFile uri;
  bool iSImageLoaded = false;
  List _result;
  String _confidence = "";
  String _name = "";
  String numbers = "";
  final ImagePicker _picker = ImagePicker();

  loadModel() async {
    var result = await Tflite.loadModel(
      labels: "assests/labels.txt",
      model: "assests/model_unquant.tflite"
    );
    print("mmm: $result");
  }

  applyModel(File file) async {
    var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2,
        threshold: 0.5,
    );
    setState(() {
      _result = res;
      String str = _result[0]["label"];
      _name = str.substring(2);
      _confidence = _result != null ? (_result[0]['confidence'] * 100.0 ).toString().substring(0,2)+ "%" : "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future getImageFromCamOrGallery(bool isCam) async{
    iSImageLoaded = true;
    var image = await _picker.getImage(source: (isCam == true ? ImageSource.camera : ImageSource.gallery));
    setState(() {
      uri = image;
      applyModel(File(uri.path));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gym Equipments Classifier'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 30),
            iSImageLoaded
            ? Center(
              child: Container(
                height: 350,
                width: 350,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(uri.path)),
                    fit: BoxFit.contain)),
                  ),
                )
              : Container(),
            SizedBox(height: 30),
            uri == null ? Text("No Image") : Text("Name: $_name \nConfidence: $_confidence")
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              getImageFromCamOrGallery(true);
            },
            child: Icon(
                Icons.camera
            ),
          ),
          SizedBox(height: 15),
          FloatingActionButton(
              onPressed: () {
                getImageFromCamOrGallery(false);
              },
              child: Icon(
                  Icons.photo_album
              ))
        ],
      ),
    );
    throw UnimplementedError();
  }

  }
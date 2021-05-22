import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;
  File _image;
  List _output;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      _isLoading = false;
      setState(() {});
    });
  }

  Future<void> getImage() async {
    var selectedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (selectedImage == null) return null;
    var image = File(selectedImage.path);
    _image = image;
  }

  Future<void> loadModel() async {
    try {
      var loaded = await Tflite.loadModel(
          model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
      print("Model loaded : " + loaded);
    } catch (e) {
      print("Model unloaded : " + e.toString());
    }
  }

  Future<void> checkImage() async {
    var output = await Tflite.runModelOnImage(
        path: _image.path,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5,
        numResults: 3);

    _output = output;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(8),
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image != null
                      ? Column(
                          children: [
                            Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                  border: Border.all(width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: FileImage(_image),
                                      fit: BoxFit.cover)),
                            ),
                            Container(
                              width: 300,
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                child: Text(
                                  'Prediction : ' + _output[0]["label"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Please upload the image that will be identified",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await getImage().then((value) async {
                            await checkImage();
                            setState(() {});
                          });
                        },
                        icon: Icon(Icons.upload_outlined),
                        label: Text("Upload"),
                      ),
                      _image != null
                          ? Container(
                              margin: EdgeInsets.only(left: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _image = null;
                                    _output = null;
                                    setState(() {});
                                  });
                                },
                                child: Icon(CupertinoIcons.restart),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

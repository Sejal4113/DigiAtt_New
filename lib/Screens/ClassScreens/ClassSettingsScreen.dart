import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/ClassScreens/ClassHomeScreen.dart';
import 'package:digiatt_new/methods/UserModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../LoginScreen.dart';

class ClassSettingsScreen extends StatefulWidget {
  var classData;
  UserModel userModel;
  ClassSettingsScreen({Key? key,required this.classData,required this.userModel}) : super(key: key);

  @override
  State<ClassSettingsScreen> createState() => _ClassSettingsScreenState(classData,userModel);
}

class _ClassSettingsScreenState extends State<ClassSettingsScreen> {
  var classData;
  var userModel;
  _ClassSettingsScreenState(this.classData,this.userModel);

  var _name = TextEditingController();
  var Urldownload = '';
  XFile? ImageFile;
  ImagePicker imagePicker = ImagePicker();
  var _description = TextEditingController();
  bool editingEnabled = false;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  if (editingEnabled) {
                    updateInfo(_name.text.trim(),_description.text.trim());
                  }

                  setState(() {
                    editingEnabled = !editingEnabled;
                  });
                },
                icon: Icon(editingEnabled ? Icons.check : Icons.edit))
          ],
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: const Text(
              'Profile'
          ),
        ),
        body:Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary
                      ],
                    )),
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height / 6,
                        ),
                        Center(
                          child: Material(
                            elevation: 4,
                            shape: CircleBorder(
                              side: BorderSide.none,
                            ),
                            child: editingEnabled
                                ? CircleAvatar(
                              radius: size.height * 0.11,
                              backgroundImage: ImageFile == null
                                  ? null
                                  : FileImage(
                                  File(ImageFile!.path)),
                            )
                                : CircleAvatar(
                              radius: size.height * 0.11,
                              backgroundImage: classData['photourl'] == ''
                                  ? null
                                  : NetworkImage(classData['photourl']),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: Container(
                              child: editingEnabled
                                  ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  getImagefromGallery();
                                },
                                icon: Icon(Icons.upload),
                                label: Text('Upload Image'),
                              )
                                  : null),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Container(
                          child: Card(
                            elevation: 10,
                            margin: const EdgeInsets.only(
                                left: 16, right: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  top: 24,
                                  bottom: 16),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    enabled: editingEnabled,
                                    controller: _name,
                                    decoration: InputDecoration(
                                        hintText: classData['name'],
                                        focusColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            )),
                                        disabledBorder:
                                        OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey))),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Description',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: _description,
                                    enabled: editingEnabled,
                                    minLines: 5,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                        hintText: classData['description'] == '' ? 'Add a New Description': classData['description'],
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            )),
                                        disabledBorder:
                                        OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey))),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: editingEnabled
                                        ? ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          editingEnabled = false;
                                        });
                                      },
                                      child: Text('Cancel'),
                                      style:
                                      ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Colors.red),
                                    )
                                        : ElevatedButton(onPressed: () {
                                          Clipboard.setData(ClipboardData(text: 'Join The class Of "${classData['name']}" using the code below: \n ${classData['id'].toString()} \n Download the DigiAtt App now.')).then((value) => snackbarKey.currentState!.showSnackBar(SnackBar(content: Text('Invite Code Copied'))));
                                    }, child: Text('Share Invite Code')),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  getImagefromGallery() async {
    ImageFile = await imagePicker.pickImage(
      source: ImageSource.gallery, imageQuality: 40,);

    setState(() {
      ImageFile;
    });
  }

  uploadFile() async {
    showDialog(
        context: NavigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ));

    if (ImageFile == null) {
      Urldownload = '';
    } else {
      final path = 'groupImages/${classData['id']}/grp_image.png';
      final file = File(ImageFile!.path);

      final ref = FirebaseStorage.instance.ref().child(path);

      UploadTask? uploadtask = ref.putFile(file);
      final snapshot = await uploadtask!.whenComplete(() => {});

      Urldownload = await snapshot.ref.getDownloadURL();
    }
  }

  Future<void> updateInfo(String name,String description) async {
    await uploadFile();

    try {
      if (!name.isEmpty) {
        await FirebaseFirestore.instance
            .collection('Classes')
            .doc(classData['id'])
            .update({'name': name});
      }
      if(!description.isEmpty){
        await FirebaseFirestore.instance.collection('Classes').doc(classData['id']).update(
            {'description' : description});
      }
      if (ImageFile != '') {

        await FirebaseFirestore.instance
            .collection('Classes')
            .doc(classData['id'])
            .update({'photourl': Urldownload});

      }
    } on Exception catch (e) {
      snackbarKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    Navigator.pop(context);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ClassHomeScreen(classData: classData, userModel: userModel)));

  }
}

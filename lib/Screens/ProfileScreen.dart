import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digiatt_new/Screens/HomeScreen.dart';
import 'package:digiatt_new/methods/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  final user1 = FirebaseAuth.instance.currentUser!;
  var _name = TextEditingController();
  var Urldownload = '';
  XFile? ImageFile;
  ImagePicker imagePicker = ImagePicker();
  var _email = TextEditingController();
  bool editingEnabled = false;

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  if (editingEnabled) {
                    updateProfile(_name.text.trim());
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
        body: FutureBuilder<UserModel?>(
          future: ReadUser(),
          builder: (context, snap) {
            if (snap.hasError) {
              snackbarKey.currentState?.showSnackBar(
                  SnackBar(content: Text('Something went wrong')));
            } else if (snap.hasData) {
              final user = snap.data;

              return user == null
                  ? const Center(
                      child: Text('No user'),
                    )
                  : Container(
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
                                          backgroundColor: Colors.black.withOpacity(0.4),
                                          child: ImageFile == null ? Icon(Icons.person,color: Colors.grey.shade700,size: 100,) :null,
                                          backgroundImage: ImageFile == null
                                              ? null
                                              : FileImage(
                                                  File(ImageFile!.path)),
                                        )
                                      : CircleAvatar(
                                          radius: size.height * 0.11,
                                          backgroundColor: user.photourl == '' ? Colors.grey.withOpacity(0.5) : null,
                                          child: user.photourl == '' ? Icon(Icons.person,color: Colors.grey.shade700,size: 100,) : null,
                                          backgroundImage: user.photourl == ''
                                              ? null
                                              : NetworkImage(user.photourl),
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
                                              hintText: user.name,
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
                                          'Email',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                              hintText: user.email,
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
                                              : ElevatedButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    elevation: 5,
                                                  ),
                                                  onPressed: () => FirebaseAuth
                                                      .instance
                                                      .signOut()
                                                      .then((value) {
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        LoginScreen()));
                                                  }),
                                                  icon: const Icon(
                                                    Icons.exit_to_app,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    'Log Out',
                                                    style: TextStyle(fontSize: 18,color: Colors.white)
                                                  ),
                                                ),
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
                    );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }

  Future updateProfile(String name) async {
    await uploadFile();

    try {
      if (!name.isEmpty) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user1.uid)
            .update({'name': name});
        await user1.updateDisplayName(name);
      }
      if (Urldownload != '') {
        
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user1.uid)
            .update({'photourl': Urldownload}).then((value) => user1.updatePhotoURL(Urldownload));

      }
    } on Exception catch (e) {
      snackbarKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    Navigator.of(context).pop();
    snackbarKey.currentState!
        .showSnackBar(SnackBar(content: Text('Profile updated')));
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
      final path = 'userImages/${user1.uid}/profile.png';
      final file = File(ImageFile!.path);

      final ref = FirebaseStorage.instance.ref().child(path);

      UploadTask? uploadtask = ref.putFile(file);
      final snapshot = await uploadtask!.whenComplete(() => {});

      Urldownload = await snapshot.ref.getDownloadURL();
    }
  }

  getImagefromGallery() async {
    ImageFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 40,);

    setState(() {
      ImageFile;
    });
  }

  Future<UserModel?> ReadUser() async {
    final Docid = FirebaseFirestore.instance.collection("Users").doc(user1.uid);
    final snapshot = await Docid.get();

    if (snapshot.exists) {
      return UserModel.fromJson(snapshot.data()!);
    }
  }
}

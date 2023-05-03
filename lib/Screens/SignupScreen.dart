import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../methods/UserModel.dart';
import '../methods/googlesigninprovider.dart';
import 'LoginScreen.dart';
import 'VerifyEmailScreen.dart';

class SignupScreen extends StatefulWidget {
  String role;

  SignupScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState(role);
}

class _SignupScreenState extends State<SignupScreen> {
  String role1;

  _SignupScreenState(this.role1);

  @override
  final FormKey = GlobalKey<FormState>();
  var _name = TextEditingController();
  var _email = TextEditingController();
  var _repassword = TextEditingController();
  var _password = TextEditingController();

  bool obscure = false, obscure1 = false;

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    void initState() {
      obscure = false;
      obscure1 = false;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ])),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.height / 10,
                ),
                Text('Register',
                    style: TextStyle(
                        fontSize: size.height * 0.07,
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  width: size.width * 0.93,
                  height: size.height * 0.6,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: FormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),
                                ),
                                TextFormField(
                                  controller: _name,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.person_outline),
                                      hintText: 'Enter Name'),
                                  validator: (value) => (value!.isEmpty ||
                                          !RegExp(r'^[a-z A-Z]+$')
                                              .hasMatch(value))
                                      ? 'Enter Valid Name'
                                      : null,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'E-mail',
                                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _email,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined),
                                    hintText: 'Enter Email',
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (email) => (email != null &&
                                          !EmailValidator.validate(
                                              _email.text.trim()))
                                      ? 'Enter a Valid Email'
                                      : null,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),
                                ),
                                TextFormField(
                                  controller: _password,
                                  obscureText: !obscure,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock_outline),
                                      hintText: 'Enter Password',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscure = !obscure;
                                          });
                                        },
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      )),
                                  validator: (value) => (_password
                                              .text.isEmpty ||
                                          (_password.text.length < 8))
                                      ? 'Enter Valid Password with min 8 characters'
                                      : null,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confirm Password',
                                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),
                                ),
                                TextFormField(
                                  controller: _repassword,
                                  obscureText: !obscure1,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline),
                                    hintText: 'Re-Enter Password',
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscure1 = !obscure1;
                                          });
                                        },
                                        icon: Icon(!obscure1
                                            ? Icons.visibility
                                            : Icons.visibility_off)),
                                  ),
                                  validator: (value) =>
                                      (_password.text.trim() !=
                                              _repassword.text.trim())
                                          ? 'Passwords don\'t Match '
                                          : null,
                                ),
                              ],
                            ),

                            Container(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (FormKey.currentState!.validate()) {
                                          Register();
                                        }
                                      },
                                      child: Text('Register'),
                                      style: ElevatedButton.styleFrom(
                                          textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),
                                          elevation: 7,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20))),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Already a User? ',
                                          style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600)),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()));
                                        },
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            decoration: TextDecoration.underline,
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                Text(
                  'Sign in with',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,letterSpacing: 1,fontSize: 16),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {

                    try {
                      final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false);
                      provider.googleLogin(context, role1);
                    } on Exception catch (e) {
                      snackbarKey.currentState
                          ?.showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          AssetImage('lib/assets/images/image.jpg')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future Register() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _email.text.trim(), password: _password.text.trim())
          .then((value) {
            if(value != null){
              value.user?.updateDisplayName(_name.text.trim());
              value.user?.updatePhotoURL("");
              value.user?.updateEmail(_email.text.trim());
            }
        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid);
        final user = UserModel(
            name: _name.text.trim(),
            email: _email.text.trim(),
            photourl: "",
            role: role1,
            inGroup: []);
        final json = user.toJson();

        docRef.set(json).then((value) {
          Navigator.of(context).pop();
          NavigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(builder: (context) => VerifyEmailScreen()));
        });
      });
    } on FirebaseAuthException catch (e) {
      snackbarKey.currentState
          ?.showSnackBar(SnackBar(content: Text(e.message!)));
      Navigator.of(context).pop();
    }
  }
}

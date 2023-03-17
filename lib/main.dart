import 'package:digiatt_new/Screens/SignupSelect.dart';
import 'package:digiatt_new/Screens/VerifyEmailScreen.dart';
import 'package:digiatt_new/methods/googlesigninprovider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final NavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
          navigatorKey: NavigatorKey,
          scaffoldMessengerKey: snackbarKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            // Define the default brightness and colors.
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color(0xFF2F58CA),
              primaryContainer: const Color(0xCC2F58CA),
              secondary: const Color(0xFF4E31AA),
            ),

            // Define the default font family.

            // Define the default `TextTheme`. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return VerifyEmailScreen();
              } else {
                return SignupSelect();
              }
            },
          )),
    );
  }
}

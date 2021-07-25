import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heyhelp/Pages/AddPost.dart';
import 'package:heyhelp/Pages/NewUser.dart';
import 'package:heyhelp/Pages/ViewPostPage.dart';
import 'package:velocity_x/velocity_x.dart';
import 'Pages/HomePage.dart';
import 'Pages/SignUpPage.dart';
import 'Pages/SplashScreen.dart';
import 'Pages/homepageview.dart';
import 'Pages/loginPage.dart';
import 'Pages/profile.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';
import 'Core/Store.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(VxState(store: MyStore(), child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initFirebaseSdk = Firebase.initializeApp();
  final _navigatorKey = new GlobalKey<NavigatorState>();

  bool userInDB = false;

  Future<bool> userExist() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((user) {
      userInDB = user.exists;
      return user.exists;
    });
  }

  Future<void> waitAndNavigate(User? user) async {
    await Future.delayed(Duration(seconds: 1), () async {
      if (user == null) {
        print('User is currently signed out!');
        _navigatorKey.currentState!.pushReplacementNamed(MyRoutes.loginPage);
      } else {
        print('User is signed in!');
        await userExist();
        if (userInDB) {
          _navigatorKey.currentState!
              .pushReplacementNamed(MyRoutes.homeScreenShower);
        } else {
          _navigatorKey.currentState!
              .pushReplacementNamed(MyRoutes.newUserPage);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: MyThemes.lightTheme(context),
      navigatorKey: _navigatorKey,
      darkTheme: MyThemes.darkTheme(context),
      // home: HomeScreenViewer(),
      home: FutureBuilder(
          future: _initFirebaseSdk,
          builder: (_, snapshot) {
            // if (snapshot.hasError) return Fluttertoast.showToast(msg: "Oops! Something gone wrong. Please try again.");

            if (snapshot.connectionState == ConnectionState.done) {
              FirebaseAuth.instance.authStateChanges().listen((User? user) {
                waitAndNavigate(user);
              });
            }
            return SplashScreen();
      }),
      //initialRoute: MyRoutes.splashSceen, // By default ye hi hota hai
      routes: {
        MyRoutes.loginPage: (context) => LoginPage(),
        MyRoutes.homePage: (context) => HomePage(),
        MyRoutes.newUserPage: (context) => NewUser(),
        MyRoutes.splashSceen: (context) => SplashScreen(),
        MyRoutes.homeScreenShower: (context) => HomeScreenViewer(),
        MyRoutes.profilePage: (context) => ProfilePage(),
        MyRoutes.addPost: (context) => AddPost(),
      },
    );
  }
}

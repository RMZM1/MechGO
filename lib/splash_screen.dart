import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/user_login.dart';
import 'package:mechaniconthego/users/customer/customer_main.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_main.dart';
import 'package:mechaniconthego/users/user_verify_email.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    //Store Data of Current User
    fAuth.currentUser != null ? AssistantMethods.readCurrentUserInfo() : null;
    checkLocationPermissionAllowed();
    goTo();
    super.initState();
  }

  goTo() {
    Timer(const Duration(seconds: 3), () async {
      if (fAuth.currentUser != null) {
        //get Users from database
        DatabaseReference ref = db.ref().child('users');
        //Get Current User
        await ref.child(fAuth.currentUser!.uid).once().then((key) {
          final snap = key.snapshot;

          if (snap.value != null) {
            //Get Data of Current User
            final userRecord = snap.value as Map;
            //Get Required Field of Current user
            var isMechanic = userRecord['isMechanic'];
            var isBlocked = userRecord['isBlocked'];
            //Set Current User
            currentFireBaseUser = fAuth.currentUser;
            //To check the user is mechanic or not
            // if Mechanic
            if (isBlocked == false) {
              if (isMechanic) {
                // check email verified
                var isEmailVerified = fAuth.currentUser!.emailVerified;
                if (!isEmailVerified) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VerifyEmail()),
                      (route) => false);
                }
                else {
                  //It should go to MechanicMain
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MechanicMain()));
                }
              }
              //If Not Mechanic
              if (!isMechanic) {
                // check email verified
                var isEmailVerified = fAuth.currentUser!.emailVerified;
                if (!isEmailVerified) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VerifyEmail()),
                      (route) => false);
                }
                else {
                  //It should go to CustomerMain
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CustomerMain()));
                }
              }
            }
            else {
              fAuth.signOut();
              Fluttertoast.showToast(
                  msg: "You Have Been Blocked By MechGo Please Contact MechGo",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const UserLogin()));
            }
          } else {
            Fluttertoast.showToast(
                msg: "An Error occurred while trying to login",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            fAuth.signOut();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const UserLogin()));
          }
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const UserLogin()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: themeColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              MdiIcons.toolbox,
              color: Colors.white,
              size: 72,
            ),
            Text(
              "MECHGO",
              style: TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontFamily: 'Manuale-Bold'),
            ),
            Text(
              "MECHANIC ON THE GO",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Manuale-Regular'),
            )
          ],
        ),
      ),
    );
  }
}

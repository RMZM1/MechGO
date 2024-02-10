import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/update/change_password.dart';
import 'package:mechaniconthego/users/user_signup.dart';
import 'package:mechaniconthego/users/customer/customer_main.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_main.dart';
import 'package:mechaniconthego/users/user_verify_email.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  var userLoginEmailCtrl = TextEditingController();
  var userLoginPasswordCtrl = TextEditingController();
  var passwordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Mechanic On The Go",
          style: pageHeadingText(),
        )),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Heading
            Container(
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.all(10.0),
              child: Text(
                "Login",
                style: mainHeadingText(),
              ),
            ),
            //Input Fields
            Container(
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  //Email Field
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: userLoginEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: textFieldsDec().copyWith(hintText: "Email"),
                    ),
                  ),
                  //Password Field
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: userLoginPasswordCtrl,
                      keyboardType: TextInputType.text,
                      obscureText: passwordHidden,
                      obscuringCharacter: "*",
                      decoration: textFieldsDec().copyWith(
                        hintText: "Password",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              if (passwordHidden == false) {
                                passwordHidden = true;
                              } else {
                                passwordHidden = false;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove_red_eye),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Login Button
            Container(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  validateCustomerLoginForm();
                },
                style: actionBtnWithThemeColor(),
                child: Text(
                  "Login",
                  style: whiteColorButtonText(),
                ),
              ),
            ),

            //Forgot Password
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Forgot Password?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>const ChangePassword()));
                    },
                    child: const Text(
                      "Click Here",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            //Don't Have an account? Signup
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't Have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserSignUp()));
                    },
                    child: const Text(
                      "SignUp",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Validate Form
  //If all conditions are satisfied than LoginMechanic
  validateCustomerLoginForm() {
    if (userLoginEmailCtrl.text.isEmpty || userLoginPasswordCtrl.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Fill All the fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (!userLoginEmailCtrl.text.contains("@")) {
      Fluttertoast.showToast(
          msg: "Email is not valid",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (userLoginPasswordCtrl.text.length < 8) {
      Fluttertoast.showToast(
          msg: "Password must be at least 8 Characters",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      loginUser();
    }
  }

  //Show a progress Circle while logging in user
  //Login
  //Hide Remove Progress circle and move to next screen
  loginUser() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });

    await fAuth
        .signInWithEmailAndPassword(
            email: userLoginEmailCtrl.text.trim(),
            password: userLoginPasswordCtrl.text.trim())
        .then((auth) {
      final User? firebaseUser = auth.user;
      if (firebaseUser != null) {
        //Check For Mechanic Record
        DatabaseReference mechanicRef = db.ref().child('users');
        mechanicRef.child(firebaseUser.uid).once().then((customerKey) {
          final snap = customerKey.snapshot;
          if (snap.value != null) {
            final userRecord = snap.value as Map;
            final isMechanic = userRecord['isMechanic'];
            var isBlocked = userRecord['isBlocked'];
            //  Now make this user current firebase User
            //  Assign it to currentFireBaseUser (global.dart)
            currentFireBaseUser = firebaseUser;

            AssistantMethods.readCurrentUserInfo();
            //Now Navigate to Mechanic if it is Mechanic else to Customer
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MechanicMain()),
                          (route) => false);
                }
              } else {
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CustomerMain()),
                          (route) => false);
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
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const UserLogin()));
            }
          } else {
            Fluttertoast.showToast(
                msg: "Something went wrong (No Record Found)",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            fAuth.signOut();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SplashScreen()));
          }
        });
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Something Went Wrong Please Try again later",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }).catchError((error) {
      Navigator.pop(context);
      String errorMessage = error.toString();
      String toastMessage;
      if (errorMessage.contains('user-not-found')) {
        toastMessage = 'No user record found';
      } else if (errorMessage.contains('network-error')) {
        toastMessage = 'Network error occurred';
      } else {
        toastMessage = 'An error occurred';
      }
      Fluttertoast.showToast(
          msg: toastMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}

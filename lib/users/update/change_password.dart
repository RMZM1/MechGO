import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController userEmailCtrl = TextEditingController();
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Heading
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            child: Text(
              "Reset Password",
              style: mainHeadingText(),
            ),
          ),
          //Text
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            width: 250,
            child: Text(
              "An Email will be sent to you to change your password",
              style: greyColorButtonText(),
            ),
          ),
          //Email Field
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: userEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: textFieldsDec().copyWith(hintText: "Email"),
            ),
          ),

          //Login Button
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                validateEmail();
              },
              style: actionBtnWithThemeColor(),
              child: Text(
                "Reset Password",
                style: whiteColorButtonText(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  validateEmail() async {
    if (userEmailCtrl.text.isNotEmpty) {
      var emailInUse =
          checkIfEmailAlreadyInUse(userEmailCtrl.text.trim().toString());
      if (await emailInUse) {
        resetPassword();
      } else {
        Fluttertoast.showToast(
            msg: "Email Not Registered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please enter your email",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  resetPassword() async {
    try {
      await fAuth.sendPasswordResetEmail(
          email: userEmailCtrl.text.trim().toString());

      Fluttertoast.showToast(
          msg: "Email has been sent",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (err) {
      Fluttertoast.showToast(
          msg: "Could not send an email please try again later",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

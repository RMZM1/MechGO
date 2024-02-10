import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/styles/styles.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> with SingleTickerProviderStateMixin{


  User? user;
  Timer? timer;

  var email = "";

  //Timer For Resending Otp
  late Animation counter;
  late AnimationController counterController;

  @override
  void initState() {
    user = fAuth.currentUser!;
    user!.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
    super.initState();
    setCounter();
  }
  setCounter(){
    counterController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    counter = Tween(begin: 30.0, end: 0.0).animate(counterController);
    counterController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    counterController.forward();

    email = currentUserData != null ? "${currentUserData!.email}":"";
  }
  @override
  void dispose() {
    counterController.dispose();
    timer!.cancel();
    super.dispose();
  }


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
        crossAxisAlignment: CrossAxisAlignment.center,
        //Heading
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Verify Email",
              style: mainHeadingText(),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  "An Email has been sent to your email",
                  style: greyColorText(),
                ),
                Text(
                  email,
                  style: greyColorText(),
                ),
              ],
            ),
          ),

          //  Did not Receive Email Resend
          Container(
            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't Receive code?"),
                Text(counter.value == 0.0
                    ? ''
                    : '${counter.value.toInt()}'),
                Visibility(
                  visible: counter.value == 0.0 ? true : false,
                  child: TextButton(
                    onPressed: (){
                      user!.sendEmailVerification();
                      Fluttertoast.showToast(
                          msg: "Email has been Sent",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
                    child: const Text(
                      "Resend",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkEmailVerified() async{
    user = fAuth.currentUser!;
    await user!.reload().then((value){
      if(user!.emailVerified){
        timer!.cancel();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context)=>const SplashScreen()));
      }
    });
  }

}

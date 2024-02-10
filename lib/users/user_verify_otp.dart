import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/user_signup.dart';
import 'package:mechaniconthego/users/customer/customer_main.dart';
import 'package:mechaniconthego/users/user_verify_email.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';
import 'package:pinput/pinput.dart';

class VerifyOTP extends StatefulWidget {
  final String name;
  final String email;
  final String countryCode;
  final String phone;
  final String password;

  const VerifyOTP({
    super.key,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.password,
  });

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  String? verificationCode;

  //Timer For Resending Otp
  late Animation count;
  late AnimationController countController;
  @override
  void initState() {
    setCount();
    super.initState();
  }
  setCount(){
    countController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    count = Tween(begin: 60.0, end: 0.0).animate(countController);
    countController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    countController.forward();
  }
  @override
  void dispose() {
    countController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Center(
            child: Text(
          "Mechanic On The Go",
          style: pageHeadingText(),
        )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //Heading
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Verify Phone Number",
                style: mainHeadingText(),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Enter The Code Sent to ${widget.countryCode + widget.phone}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: Pinput(
                controller: otpController,
                focusNode: otpFocusNode,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinAnimationType: PinAnimationType.rotation,
                onChanged: (value) {
                  setState(() {
                    verificationCode = value;
                  });
                },
              ),
            ),

            //Verify Button
            Container(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: verifyOtp,
                style: actionBtnWithThemeColor(),
                child: Text(
                  "Verify",
                  style: whiteColorButtonText(),
                ),
              ),
            ),
            //  Did not Receive Code Resend
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't Receive code?"),
                  Text(count.value == 0.0
                      ? ''
                      : '${count.value.toInt()}'),
                  Visibility(
                    visible: count.value == 0.0 ? true : false,
                    child: TextButton(
                      onPressed: resendOtp,
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
      ),
    );
  }

  verifyOtp() async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false, //it should not disappear on user click
          builder: (BuildContext context) {
            return const ProgressDialog(message: "Processing! Please Wait ");
          });
      //Phone Number Verification
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: UserSignUp.verify, smsCode: verificationCode!);

      await fAuth.signInWithCredential(credential).then((auth) {
        //  if user is registered successfully
        //Save its data i.e Number name
        final User? firebaseUser = auth.user;
        if (firebaseUser != null) {
          //Now Link email and password with this user
          AuthCredential emailCredential = EmailAuthProvider.credential(
              email: widget.email, password: widget.password);
          firebaseUser.linkWithCredential(emailCredential);

          //To store in database
          Map userMap = {
            "id": firebaseUser.uid,
            "name": widget.name,
            "email": widget.email,
            "phone": widget.countryCode + widget.phone,
            "ratings": 0,
            "noOfRatings": 0,
            "isMechanic": false,
            "mechanicInfo": "NiL",
            "priceList": "NiL",
            "isBlocked": false,
          };

          // Now Save the above data in realtime database
          // Create an instance of user in Database and save it as database reference
          DatabaseReference customerRef = db.ref().child("users");
          //Now Adding Newly Registered user in database
          customerRef.child(firebaseUser.uid).set(userMap);

          //  Now make this user current firebase User
          //  Assign it to currentFireBaseUser (global.dart)
          currentFireBaseUser = firebaseUser;
          //Here Need To Store Phone Number in separate DataBase for searching whether PhoneNUmber exist or not
          DatabaseReference phoneRef = db.ref().child("registeredPhoneNumbers");
          var phone = widget.countryCode + widget.phone;
          phoneRef.child(phone).set({
            'phoneNumber': phone,
          });

          AssistantMethods.readCurrentUserInfo();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const VerifyEmail()),
              (route) => false);
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
        if (errorMessage.contains('network-error')) {
          toastMessage = 'Network error occurred';
        } else {
          toastMessage = 'An error occurred';
        }
        Fluttertoast.showToast(
            msg: "Signup Error:$toastMessage",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    } catch (error) {
      Navigator.pop(context);

      String errorMessage = error.toString();
      String toastMessage;
      if (errorMessage.contains('network-error')) {
        toastMessage = 'Network error occurred';
      } else {
        toastMessage = 'An error occurred';
      }

      Fluttertoast.showToast(
          msg: 'Verify OTP: $toastMessage',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  resendOtp() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });
    //Send A verification Code (OTP) to given Number
    await fAuth.verifyPhoneNumber(
        phoneNumber: widget.countryCode + widget.phone, //Number to be verified
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException exception) {},
        codeSent: (String verificationId, int? resendToken) {
          UserSignUp.verify = verificationId;
          Navigator.pop(context);
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }
}

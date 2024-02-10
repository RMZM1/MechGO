import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/update/update_phone.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';
import 'package:pinput/pinput.dart';

class VerifyNewPhone extends StatefulWidget {
  final String countryCode;
  final String phone;
  const VerifyNewPhone(
      {Key? key, required this.countryCode, required this.phone})
      : super(key: key);

  @override
  State<VerifyNewPhone> createState() => _VerifyNewPhoneState();
}

class _VerifyNewPhoneState extends State<VerifyNewPhone>
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

  setCount() {
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
                  Text(count.value == 0.0 ? '' : '${count.value.toInt()}'),
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
          verificationId: UpdatePhone.verify, smsCode: verificationCode!);
      //Update phone Number
      currentFireBaseUser!.updatePhoneNumber(credential).then((value) {
        //add new phone in registeredPhoneNumbers
        DatabaseReference phoneRef = db.ref().child("registeredPhoneNumbers");
        var phone = widget.countryCode + widget.phone;
        phoneRef.child(phone).set({
          'phoneNumber': phone,
        });
        //Delete previous Phone Number
        phoneRef.child(currentUserData!.phone!).remove();
        //Now change phone number in db
        DatabaseReference ref = db.ref().child("users");
        ref.child(currentFireBaseUser!.uid).update({"phone": phone});
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Successfully Updated",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false);
      }).catchError((e) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Error:$e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: '$e',
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
          UpdatePhone.verify = verificationId;
          Navigator.pop(context);
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }
}

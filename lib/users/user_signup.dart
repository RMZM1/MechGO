import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/user_login.dart';
import 'package:mechaniconthego/users/user_verify_otp.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({Key? key}) : super(key: key);

  static String verify = '';
  @override
  State<UserSignUp> createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  var userSignUpNameCtrl = TextEditingController();
  var userSignUpEmailCtrl = TextEditingController();
  var userSignUpPhoneCtrl = TextEditingController();
  var userSignUpPasswordCtrl = TextEditingController();
  var passwordHidden = true;

  String countryCodeDigits = "+92";

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
          children: [
            //Heading
            Container(
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.all(20.0),
              child: Text(
                "Signup",
                style: mainHeadingText(),
              ),
            ),
            //Input Fields
            Container(
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  //Name Field
                  Expanded(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: userSignUpNameCtrl,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          // only accept letters from a to z
                          FilteringTextInputFormatter(RegExp(r'[a-zA-Z, ]'),
                              allow: true)
                        ],
                        maxLength: 15,
                        decoration: textFieldsDec().copyWith(hintText: "Name"),
                      ),
                    ),
                  ),
                  //Email Field
                  Expanded(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: userSignUpEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: textFieldsDec().copyWith(hintText: "Email"),
                      ),
                    ),
                  ),

                  //Phone Number Field
                  Expanded(
                    flex: 0,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 0,
                            child: CountryCodePicker(
                              onChanged: (country) {
                                setState(() {
                                  countryCodeDigits = country.dialCode!;
                                });
                              },
                              showCountryOnly: false,
                              initialSelection: 'PK',
                              favorite: const ['+92', 'PK'],
                              showOnlyCountryWhenClosed: false,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: const EdgeInsets.all(5),
                                child: const Text(
                                  "|",
                                  style: TextStyle(fontSize: 32),
                                )),
                          ),
                          Expanded(
                            flex: 8,
                            child: TextField(
                              controller: userSignUpPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: "Phone Number",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //Password Field
                  Expanded(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: userSignUpPasswordCtrl,
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
                  ),
                ],
              ),
            ),
            //Signup Button
            Container(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  validateCustomerSignupForm();
                },
                style: actionBtnWithThemeColor(),
                child: Text(
                  "Signup",
                  style: whiteColorButtonText(),
                ),
              ),
            ),
            //Already have an account? Sign in
            Container(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already Have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserLogin()));
                    },
                    child: const Text(
                      "Login",
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
  //If all conditions are satisfied than saveCustomerInfo

  validateCustomerSignupForm() {
    if (userSignUpNameCtrl.text.isEmpty ||
        userSignUpEmailCtrl.text.isEmpty ||
        userSignUpPhoneCtrl.text.isEmpty ||
        userSignUpPasswordCtrl.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Fill All the fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (userSignUpNameCtrl.text.length < 3) {
      Fluttertoast.showToast(
          msg: "Name must contain 3 characters",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    //S means Character without space
    //D means characters that are not Digits
    else if (!RegExp(r'\D+\S+@\S+\.\S+').hasMatch(userSignUpEmailCtrl.text)) {
      Fluttertoast.showToast(
          msg: "Email is not valid",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (userSignUpPhoneCtrl.text.length < 4) {
      Fluttertoast.showToast(
          msg: "Invalid Phone Number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (userSignUpPasswordCtrl.text.length < 8) {
      Fluttertoast.showToast(
          msg: "Password must be at least 8 Characters",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      checkEmailAndPhoneAlreadyExist();
    }
  }

  checkEmailAndPhoneAlreadyExist() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });
    var emailInUse =
        checkIfEmailAlreadyInUse(userSignUpEmailCtrl.text.trim().toString());
    var phone = countryCodeDigits + userSignUpPhoneCtrl.text.trim().toString();
    var phoneInUse = checkIfPhoneAlreadyInUse(phone);

    //If Email is already registered than show error message
    if (await emailInUse) {
      () => Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Email Already Registered",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    //If Phone is already registered than show error message
    else if (await phoneInUse) {
      () => Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Phone Already Registered",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      sendOTP();
    }
  }

  //Take All the collected info to Customer OTP to verify and save User
  sendOTP() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });
    //Send A verification Code (OTP) to given Number

    await fAuth.verifyPhoneNumber(
        phoneNumber: countryCodeDigits +
            userSignUpPhoneCtrl.text.trim().toString(), //Number to be verified
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException exception) {},
        codeSent: (String verificationId, int? resendToken) {
          UserSignUp.verify = verificationId;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyOTP(
                        name: userSignUpNameCtrl.text.trim().toString(),
                        email: userSignUpEmailCtrl.text.trim().toString(),
                        countryCode: countryCodeDigits,
                        phone: userSignUpPhoneCtrl.text.trim().toString(),
                        password: userSignUpPasswordCtrl.text.trim().toString(),
                      )));
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }
}

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/update/verify_new_phone.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class UpdatePhone extends StatefulWidget {
  const UpdatePhone({Key? key}) : super(key: key);
  static String verify = '';
  @override
  State<UpdatePhone> createState() => _UpdatePhoneState();
}

class _UpdatePhoneState extends State<UpdatePhone> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var newPhoneCtrl = TextEditingController();
  String countryCodeDigits = "+92";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
            child: Text(
          "Mechanic On The Go",
          style: pageHeadingText(),
        )),
        automaticallyImplyLeading:
            false, // this will hide Drawer hamburger icon
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Heading
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            child: Text(
              "Update Phone",
              style: mainHeadingText(),
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
                      controller: newPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: "New Phone Number",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Update Button
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                checkPhone();
              },
              style: actionBtnWithThemeColor(),
              child: Text(
                "Update",
                style: whiteColorButtonText(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkPhone() async {
    var phone = countryCodeDigits + newPhoneCtrl.text.trim().toString();
    var isPhone = checkIfPhoneAlreadyInUse(phone);
    if(await isPhone){
      Fluttertoast.showToast(
          msg: "Phone Number Already Registered",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    else{
      sendOTP();
    }
  }
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
            newPhoneCtrl.text.trim().toString(), //Number to be verified
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException exception) {},
        codeSent: (String verificationId, int? resendToken) {
          UpdatePhone.verify = verificationId;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyNewPhone(
                        countryCode: countryCodeDigits,
                        phone: newPhoneCtrl.text.trim().toString(),
                      )));
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }
}

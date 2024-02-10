import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';

class UpdateEmail extends StatefulWidget {
  const UpdateEmail({Key? key}) : super(key: key);

  @override
  State<UpdateEmail> createState() => _UpdateEmailState();
}

class _UpdateEmailState extends State<UpdateEmail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController newEmailCtrl = TextEditingController();
  var passwordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: UserNavigationDrawer(
        user: currentUserData,
      ),
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
              "Update Email",
              style: mainHeadingText(),
            ),
          ),

          //Email Field
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: newEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: textFieldsDec().copyWith(hintText: "New Email"),
            ),
          ),
          //Password Field
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordCtrl,
              keyboardType: TextInputType.text,
              obscureText: passwordHidden,
              obscuringCharacter: "*",
              decoration: textFieldsDec().copyWith(
                hintText: "Current Password",
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


          //Update Button
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                updateEmail();
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

  updateEmail() async {
    if(passwordCtrl.text.isNotEmpty && newEmailCtrl.text.isNotEmpty){
      var currentEmail = currentUserData!.email!;
      var currentPassword = passwordCtrl.text.trim().toString();
      var newEmail = newEmailCtrl.text.trim().toString();
      //First ReAuthenticate user
      AuthCredential credential = EmailAuthProvider.credential(email: currentEmail, password: currentPassword);
      currentFireBaseUser!.reauthenticateWithCredential(credential).then((value){
        //Now Update in Auth
        currentFireBaseUser!.updateEmail(newEmail).then((value) async {
          //Now Update in DB
          DatabaseReference userRef = db.ref().child('users');
          await userRef.child(currentFireBaseUser!.uid).update({
            "email": newEmailCtrl.text.trim().toString(),
          })
              .then((value) {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Successfully Updated",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                    (route) => false);
          })
              .catchError((error) {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "$error",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          });
        });
      });
    }
    else{
      Fluttertoast.showToast(
          msg: "Please Fill the Field",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

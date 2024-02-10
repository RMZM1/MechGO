import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';

class UpdateCNIC extends StatefulWidget {
  const UpdateCNIC({Key? key}) : super(key: key);

  @override
  State<UpdateCNIC> createState() => _UpdateCNICState();
}

class _UpdateCNICState extends State<UpdateCNIC> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController userCNICCtrl = TextEditingController();
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
              "Update CNIC",
              style: mainHeadingText(),
            ),
          ),

          //CNIC Field
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: userCNICCtrl,
              keyboardType: TextInputType.text,
              decoration: textFieldsDec().copyWith(hintText: "CNIC"),
            ),
          ),

          //Update Button
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                updateCNIC();
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

  updateCNIC() async {
    if (userCNICCtrl.text.isNotEmpty) {
      var cnicRegistered =
          checkIfCNICAlreadyInUse(userCNICCtrl.text.trim().toString());
      if (await cnicRegistered) {
        Fluttertoast.showToast(
            msg: "CNIC is Already Registered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        DatabaseReference cnicRef = db.ref().child('registeredCNIC');
        cnicRef
            .child(currentUserData!.mechanicInfo["mechanicCNIC"])
            .remove()
            .then((value) {
          cnicRef.child(userCNICCtrl.text.trim().toString()).set({
            "cnic": userCNICCtrl.text.trim().toString(),
          }).then((value) async {
            DatabaseReference userRef = db.ref().child('users');
            await userRef
                .child(currentFireBaseUser!.uid)
                .child("mechanicInfo")
                .update({
              "mechanicCNIC": userCNICCtrl.text.trim().toString(),
            }).then((value) {
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
            });
          });
        }).catchError((error) {
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
      }
    } else {
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

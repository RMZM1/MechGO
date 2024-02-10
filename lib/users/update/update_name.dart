import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';

class UpdateName extends StatefulWidget {
  const UpdateName({Key? key}) : super(key: key);

  @override
  State<UpdateName> createState() => _UpdateNameState();
}

class _UpdateNameState extends State<UpdateName> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController userNameCtrl = TextEditingController();
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
              "Update Name",
              style: mainHeadingText(),
            ),
          ),


          //Name Field
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            child: TextField(
              controller: userNameCtrl,
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

          //Update Button
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                updateName();
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

  updateName() async {
    if(userNameCtrl.text.isNotEmpty){
      DatabaseReference userRef = db.ref().child('users');
      await userRef.child(currentFireBaseUser!.uid).update({
        "name": userNameCtrl.text.trim().toString(),
      }).then((value) {
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

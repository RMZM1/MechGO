import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/update/set_price_list.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_main.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class RegisterMechanic extends StatefulWidget {
  const RegisterMechanic({Key? key}) : super(key: key);

  @override
  State<RegisterMechanic> createState() => _RegisterMechanicState();
}

class _RegisterMechanicState extends State<RegisterMechanic> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> mechanicTypes = ["Car Mechanic", "Bike Mechanic"];
  String? selectedMechanicType;

  var mechanicRegisterCNICCtrl = TextEditingController();

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            //  Custom Drawer Hamburger button and Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //  Custom Drawer Hamburger button
                Container(
                  margin: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: () {
                      //  It will open Drawer
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: const CircleAvatar(
                      backgroundColor: themeColor,
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                //Heading
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Center(
                      child: Text(
                    'Become Mechanic',
                    style: mainHeadingText(),
                  )),
                ),
              ],
            ),
            //Input Fields
            //Mechanic Information
            Container(
              margin: const EdgeInsets.all(20),
              child: Center(
                  child: Text(
                'Mechanic Information',
                style: mainHeadingText(),
              )),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  //Mechanic Type I.e Car, Bike
                  Expanded(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          //background color of dropdown button
                          color: Colors.transparent,
                          //border of dropdown button
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            iconSize: 32,
                            dropdownColor: Colors.white,
                            underline: Container(), //remove underline
                            isExpanded: true,
                            hint: const Text(
                              "Mechanic Type",
                            ),
                            value: selectedMechanicType,
                            onChanged: (newValue) {
                              setState(() {
                                selectedMechanicType = newValue.toString();
                              });
                            },
                            items: mechanicTypes.map((mechanicType) {
                              return DropdownMenuItem(
                                value: mechanicType,
                                child: Text(
                                  mechanicType,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //CNIC Field
                  Expanded(
                    flex: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: mechanicRegisterCNICCtrl,
                        keyboardType: TextInputType.text,
                        decoration: textFieldsDec().copyWith(hintText: "CNIC"),
                      ),
                    ),
                  ),
                ],
              ),
            ),



            //Save Register Button
            Container(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: validateInformationForm,
                style: actionBtnWithThemeColor(),
                child: Text(
                  "Next",
                  style: whiteColorButtonText(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  validateInformationForm() async {
    if (mechanicRegisterCNICCtrl.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Enter CNIC",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (selectedMechanicType == null) {
      Fluttertoast.showToast(
          msg: "Please Select Mechanic Type",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      var cnicRegistered = checkIfCNICAlreadyInUse(
          mechanicRegisterCNICCtrl.text.trim().toString());
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
        updateUser();
      }
    }
  }

  updateUser() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });



    var mechanicInfoMap = {
      "mechanicType": selectedMechanicType,
      "mechanicCNIC": mechanicRegisterCNICCtrl.text.trim().toString(),
    };
    DatabaseReference userRef = db.ref().child('users');
    await userRef.child(currentFireBaseUser!.uid).update({
      "isMechanic": true,
      "mechanicInfo": mechanicInfoMap,
    }).then((value) {
      DatabaseReference cnicRef = db.ref().child('registeredCNIC');
      var cnic = mechanicRegisterCNICCtrl.text.trim().toString();
      cnicRef.child(cnic).set({
        "cnic": cnic,
      });
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Successfully Registered",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SetPriceList()),
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
}

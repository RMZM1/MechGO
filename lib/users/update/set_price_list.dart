import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class SetPriceList extends StatefulWidget {
  const SetPriceList({Key? key}) : super(key: key);

  @override
  State<SetPriceList> createState() => _SetPriceListState();
}

class _SetPriceListState extends State<SetPriceList> with SingleTickerProviderStateMixin {

  //Battery
  var priceBatteryMinCtrl = TextEditingController();
  var priceBatteryMaxCtrl = TextEditingController();
  //Tyre
  var priceTyreMinCtrl = TextEditingController();
  var priceTyreMaxCtrl = TextEditingController();
  //Brakes
  var priceBrakesMinCtrl = TextEditingController();
  var priceBrakesMaxCtrl = TextEditingController();
  //Head Lights
  var priceHeadLightsMinCtrl = TextEditingController();
  var priceHeadLightsMaxCtrl = TextEditingController();
  //Tail Lights
  var priceTailLightsMinCtrl = TextEditingController();
  var priceTailLightsMaxCtrl = TextEditingController();
  //Side Mirrors
  var priceSideMirrorsMinCtrl = TextEditingController();
  var priceSideMirrorsMaxCtrl = TextEditingController();
  //Suspensions
  var priceSuspensionsMinCtrl = TextEditingController();
  var priceSuspensionsMaxCtrl = TextEditingController();
  //Oil Change
  var priceOilChangeCtrl = TextEditingController();
  //Puncture
  var pricePunctureCtrl = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            //Price List
            Container(
              margin: const EdgeInsets.all(20),
              child: Center(
                  child: Text(
                    'Price List',
                    style: mainHeadingText(),
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  //Battery
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                              "Battery:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceBatteryMinCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Min Price"),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceBatteryMaxCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Max Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Tyre
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                              "Tyre:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceTyreMinCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Min Price"),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceTyreMaxCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Max Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Brakes
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                              "Brakes:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceBrakesMinCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Min Price"),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceBrakesMaxCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Max Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Head Lights
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                              "Head Lights:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceHeadLightsMinCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Min Price"),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceHeadLightsMaxCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Max Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Tail Lights
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                              "Tail Lights:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceTailLightsMinCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Min Price"),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceTailLightsMaxCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Max Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Side Mirrors
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                              "Side Mirrors:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceSideMirrorsMinCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Min Price"),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceSideMirrorsMaxCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Max Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Suspensions
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text(
                              "Suspensions:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceSuspensionsMinCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Min Price"),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceSuspensionsMaxCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Max Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Oil Change
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              "Oil Change:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: priceOilChangeCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Oil Change Price"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //  Puncture
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              "Puncture:",
                              style: greyColorButtonText(),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: pricePunctureCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                // only accept Number from 0 to 9
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              decoration: textFieldsDec()
                                  .copyWith(hintText: "Price / Puncture"),
                            ),
                          ),
                        ),
                      ],
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
                  "Save",
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
    if (priceBatteryMinCtrl.text.isEmpty ||
        priceBatteryMaxCtrl.text.isEmpty ||
        priceTyreMinCtrl.text.isEmpty ||
        priceTyreMaxCtrl.text.isEmpty ||
        priceBrakesMinCtrl.text.isEmpty ||
        priceBrakesMaxCtrl.text.isEmpty ||
        priceHeadLightsMinCtrl.text.isEmpty ||
        priceHeadLightsMaxCtrl.text.isEmpty ||
        priceTailLightsMinCtrl.text.isEmpty ||
        priceTailLightsMaxCtrl.text.isEmpty ||
        priceSideMirrorsMinCtrl.text.isEmpty ||
        priceSideMirrorsMaxCtrl.text.isEmpty ||
        priceSuspensionsMinCtrl.text.isEmpty ||
        priceSuspensionsMaxCtrl.text.isEmpty ||
        priceOilChangeCtrl.text.isEmpty ||
        pricePunctureCtrl.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Fill all the price list Fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
        updateUserPriceList();
      }
    }


  updateUserPriceList() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });

    var priceListMap = {
      "Battery": {
        "minPrice": priceBatteryMinCtrl.text.trim().toString(),
        "maxPrice": priceBatteryMaxCtrl.text.trim().toString(),
      },
      "Tyre": {
        "minPrice": priceTyreMinCtrl.text.trim().toString(),
        "maxPrice": priceTyreMaxCtrl.text.trim().toString(),
      },
      "Brakes": {
        "minPrice": priceBrakesMinCtrl.text.trim().toString(),
        "maxPrice": priceBrakesMaxCtrl.text.trim().toString(),
      },
      "HeadLights": {
        "minPrice": priceHeadLightsMinCtrl.text.trim().toString(),
        "maxPrice": priceHeadLightsMaxCtrl.text.trim().toString(),
      },
      "TailLights": {
        "minPrice": priceTailLightsMinCtrl.text.trim().toString(),
        "maxPrice": priceTailLightsMaxCtrl.text.trim().toString(),
      },
      "SideMirrors": {
        "minPrice": priceSideMirrorsMinCtrl.text.trim().toString(),
        "maxPrice": priceSideMirrorsMaxCtrl.text.trim().toString(),
      },
      "Suspension": {
        "minPrice": priceSuspensionsMinCtrl.text.trim().toString(),
        "maxPrice": priceSuspensionsMaxCtrl.text.trim().toString(),
      },
      "OilChange": {
        "price": priceOilChangeCtrl.text.trim().toString(),
      },
      "Puncture": {"price": pricePunctureCtrl.text.trim().toString()}
    };

    DatabaseReference userRef = db.ref().child('users');
    await userRef.child(currentFireBaseUser!.uid).update({
      "priceList": priceListMap,
    }).then((value) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Successfully Price List Updated",
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

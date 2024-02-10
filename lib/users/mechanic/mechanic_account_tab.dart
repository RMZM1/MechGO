import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mechaniconthego/assistants/stripe_backend_assistant.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/update/set_price_list.dart';
import 'package:mechaniconthego/users/update/update_cnic.dart';
import 'package:mechaniconthego/users/update/update_email.dart';
import 'package:mechaniconthego/users/update/update_name.dart';
import 'package:mechaniconthego/users/update/update_phone.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class MechanicAccount extends StatefulWidget {
  const MechanicAccount({Key? key}) : super(key: key);

  @override
  State<MechanicAccount> createState() => _MechanicAccountState();
}

class _MechanicAccountState extends State<MechanicAccount> {
  String? existingImageUrl;
  late StreamSubscription _sub;

  @override
  void initState() {
    initUniLinks();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Heading
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              child: Center(
                  child: Text(
                'My Account',
                style: mainHeadingText(),
              )),
            ),

            currentUserData!.profilePic == null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 8,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: () {
                          uploadImage();
                        },
                        child: Ink.image(
                          image: const AssetImage("assets/images/person.png"),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 8,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: InkWell(
                        onTap: () {
                          uploadImage();
                        },
                        child: Ink.image(
                          image: NetworkImage("${currentUserData!.profilePic}"),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

            //Ratings
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBarIndicator(
                    rating: double.parse(currentUserData!.ratings.toString()),
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${currentUserData!.noOfRatings!}",
                      style: greyColorButtonText(),
                    ),
                  ),
                ],
              ),
            ),
            //Name
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: textButtonContainerDecoration(),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateName()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.person,
                            color: Color.fromRGBO(59, 59, 59, 1.0),
                            size: 32,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name",
                                style: greyColorText(),
                              ),
                              Text(
                                "${currentUserData!.name}",
                                style: greyColorButtonText(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Color.fromRGBO(59, 59, 59, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Email
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: textButtonContainerDecoration(),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateEmail()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.email,
                            color: Color.fromRGBO(59, 59, 59, 1.0),
                            size: 32,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                style: greyColorText(),
                              ),
                              Text(
                                "${currentUserData!.email}",
                                style: greyColorButtonText(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Color.fromRGBO(59, 59, 59, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Phone
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: textButtonContainerDecoration(),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdatePhone()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.phone_android_outlined,
                            color: Color.fromRGBO(59, 59, 59, 1.0),
                            size: 32,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Phone",
                                style: greyColorText(),
                              ),
                              Text(
                                "${currentUserData!.phone}",
                                style: greyColorButtonText(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Color.fromRGBO(59, 59, 59, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //CNIC
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: textButtonContainerDecoration(),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateCNIC()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            MdiIcons.card,
                            color: Color.fromRGBO(59, 59, 59, 1.0),
                            size: 32,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CNIC",
                                style: greyColorText(),
                              ),
                              Text(
                                "${currentUserData!.mechanicInfo["mechanicCNIC"]}",
                                style: greyColorButtonText(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Color.fromRGBO(59, 59, 59, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Price List
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: textButtonContainerDecoration(),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SetPriceList()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.attach_money,
                            color: Color.fromRGBO(59, 59, 59, 1.0),
                            size: 32,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price List",
                                style: greyColorText(),
                              ),
                              Text(
                                "Update Price List",
                                style: greyColorButtonText(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Color.fromRGBO(59, 59, 59, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //Connect Stripe Account
            currentUserData!.stripeOnBoardingComplete == true
                ? Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    decoration: textButtonContainerDecoration(),
                    child: TextButton(
                      onPressed: () {
                        //  Launch a url to sign in to stripe connect express
                        var link = 'https://connect.stripe.com/express_login';
                          // var link = 'http://localhost:8080/getStripeConnectedAccount?accountId=acct_1NR8q7Q3sXTZDruc';
                        final Uri url = Uri.parse(link);
                        _launchUrl(url);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.account_box,
                                  color: Color.fromRGBO(59, 59, 59, 1.0),
                                  size: 32,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Stripe",
                                      style: greyColorText(),
                                    ),
                                    Text(
                                      "Go to Stripe Account",
                                      style: greyColorButtonText(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_forward_ios_sharp,
                              color: Color.fromRGBO(59, 59, 59, 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    decoration: textButtonContainerDecoration(),
                    child: TextButton(
                      onPressed: () {
                        onBoardMechanic();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.account_box,
                                  color: Color.fromRGBO(59, 59, 59, 1.0),
                                  size: 32,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Online Payments",
                                      style: greyColorText(),
                                    ),
                                    Text(
                                      "Connect To Stripe",
                                      style: greyColorButtonText(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_forward_ios_sharp,
                              color: Color.fromRGBO(59, 59, 59, 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

            //Logout Button
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: textButtonContainerDecoration(),
              child: TextButton(
                onPressed: () {
                  goOffline();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Logout",
                        style: greyColorButtonText(),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.logout,
                        color: Color.fromRGBO(59, 59, 59, 1.0),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goOffline() {
    Geofire.initialize("onlineMechanics");
    Geofire.removeLocation(currentFireBaseUser!.uid);
    //Set the Job status of mechanic to Null i.e delete it
    DatabaseReference? ref = db
        .ref()
        .child("users")
        .child(currentFireBaseUser!.uid)
        .child("mechanicInfo")
        .child("jobStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;
    fAuth.signOut();
    isMechanicAvailable = false;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SplashScreen()));
  }

  uploadImage() async {
    //Check whether there is a profile pic or not
    await retrieveExistingImageUrl();

    // Step 2: Pick a new image
    final imagePath = await pickImage();
    if (imagePath == null) {
      return; // No image was selected
    }
    String uniqueFileName =
        "${currentUserData!.name}+${DateTime.now().microsecondsSinceEpoch.toString()}";
    //  Firebase Storage
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('profilePics')
        .child(uniqueFileName);

    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Uploading! Please Wait ");
        });

    //First check that if there is already a profile pic if it is than delete and upload new

    try {
      final uploadTask = storageReference.putFile(File(imagePath));

      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        final imageUrl = await snapshot.ref.getDownloadURL();
        final databaseReference = db
            .ref()
            .child('users')
            .child(currentUserData!.id!)
            .child('profilePic');
        await databaseReference.set(imageUrl);

        //Delete Existing Profile Pic If exist
        if (existingImageUrl != null) {
          final existingStorageReference =
              FirebaseStorage.instance.refFromURL(existingImageUrl!);
          await existingStorageReference.delete();
        }

        // Success! Do something with the download URL or navigate to the next screen.
        Navigator.pop(context);
        await Fluttertoast.showToast(
            msg: "Image Uploaded Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SplashScreen()));
      } else {
        Navigator.pop(context);
        // Error occurred during image upload.
        await Fluttertoast.showToast(
            msg:
                "An Error occurred while uploading image please try Again later",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (err) {
      Navigator.pop(context);
      await Fluttertoast.showToast(
          msg: "Something went wrong while uploading image",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<String?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return pickedFile.path;
    }

    return null;
  }

  Future<void> retrieveExistingImageUrl() async {
    final databaseReference =
        db.ref().child('users').child(currentUserData!.id!).child('profilePic');
    await databaseReference.once().then((data) {
      existingImageUrl = data.snapshot.value.toString();
    });
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(
        url,
      mode: LaunchMode.externalApplication
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> initUniLinks() async {
    try {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          if (uri.scheme == 'mechgo') {
            handleDeepLinkParameters(context, uri.queryParameters);
          }
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Deep Link Error",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);    }
  }

  void handleDeepLinkParameters(BuildContext context, Map<String, String> queryParameters,)
  {
    var stripeOnBoardingComplete = queryParameters['stripeOnBoardingComplete'];
    // var message = queryParameters['message'];
    if (stripeOnBoardingComplete == 'true') {
      db.ref().child("users").child(currentFireBaseUser!.uid).update({
        "stripeOnBoardingComplete": true,
      }).then((value) {
        Fluttertoast.showToast(
            msg: "Status Updated",
            toastLength: Toast.LENGTH_LONG,
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
    } else {
      Fluttertoast.showToast(
          msg: "Could not retrieve Stripe Account",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void onBoardMechanic() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });
    try {
      var response = await StripeBackendService.createMechanicAccount();
      Navigator.pop(context);
      var success = response['success'];
      if (success == true) {
        //Save account Id to firebase
        var accountId = response['accountId'];
        await db
            .ref()
            .child('users')
            .child(currentFireBaseUser!.uid)
            .update({"stripeAccountId": accountId});
        // Launch Url for mechanic to link its bank and other details to stripe
        var urlRes = response['url'];
        final Uri url = Uri.parse(urlRes);
        _launchUrl(url);
      } else {
        var message = response['message'];
        Fluttertoast.showToast(
            msg: "$message",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "$e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/update/update_email.dart';
import 'package:mechaniconthego/users/update/update_name.dart';
import 'package:mechaniconthego/users/update/update_phone.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class CustomerAccount extends StatefulWidget {
  const CustomerAccount({Key? key}) : super(key: key);

  @override
  State<CustomerAccount> createState() => _CustomerAccountState();
}

class _CustomerAccountState extends State<CustomerAccount> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? existingImageUrl;

  @override
  void initState() {
    super.initState();
  }

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
                    'My Account',
                    style: mainHeadingText(),
                  )),
                ),
              ],
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const UpdateName()));
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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const UpdateEmail()));
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

            //Logout Button
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: textButtonContainerDecoration(),
              child: TextButton(
                onPressed: () {
                  fAuth.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SplashScreen()));
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
          final existingStorageReference = FirebaseStorage.instance
              .refFromURL(existingImageUrl!);
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const SplashScreen()));
      }
      else {
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
    }
    catch (err) {
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
    final databaseReference = db.ref().child('users')
        .child(currentUserData!.id!).child('profilePic');
    await databaseReference.once().then((data){
      existingImageUrl = data.snapshot.value.toString();
    });
  }

}

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/notifications/push_notification_system.dart';
import 'package:mechaniconthego/styles/styles.dart';

class MechanicHome extends StatefulWidget {
  const MechanicHome({Key? key}) : super(key: key);

  @override
  State<MechanicHome> createState() => _MechanicHomeState();
}

class _MechanicHomeState extends State<MechanicHome> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  var geoLocator = Geolocator();

  //Default MAP Position Later changed to Current position of User
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 20,
  );

  @override
  void initState() {
    checkMechanicOnlineStatus();
    readCurrentMechanicsInfo();
    getUserRatings();
    getMechanicsAllRepairRequestsHistory();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
              newGoogleMapController = controller;
              // googleMapBlackTheme(newGoogleMapController);
              //Update User Position
              locateUserPosition();
            },
          ),

          //If Mechanic is Online Than Show Maps
          //  Else Show Blurry Screen with a button to get online
          isMechanicAvailable
              ? Positioned(
                  top: 36,
                  left: 22,
                  child: ElevatedButton(
                    //GO Offline
                    onPressed: goOffline,
                    style: actionBtnWithThemeColor(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Go Offline",
                          style: whiteColorButtonText(),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: const Color.fromRGBO(0, 0, 0, 0.93),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: goOnline,
                            style: actionBtnWithThemeColor(),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.wifi,
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Go Online",
                                  style: whiteColorButtonText(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "You Are Currently Offline",
                        style: greyColorButtonText(),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  //Check mechanic status
  checkMechanicOnlineStatus() async {
    if(isMechanicAvailable == false){
      await db.ref().child("onlineMechanics").once().then((data) {
        for (var i in data.snapshot.children) {
          var key = i.key;
          if (key == currentFireBaseUser!.uid) {
            setState(() {
              isMechanicAvailable = true;
              return;
            });
          }
        }
      });
    }

  }

  //Get Current Position of user
  locateUserPosition() async {
    //Get Current Location
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //Assign it to userCurrentPosition
    userCurrentPosition = currentPosition;

    //now get latitude and longitude
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    //  Now Assign these values to camera position
    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 15,
    );
    //  Now Give this camera Position to google map controller
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //  Get Human Readable address
    readAddress();
  }

  readAddress () async{
    await AssistantMethods.getHumanReadableAddress(
        userCurrentPosition!, context);
  }

  Future<void> goOnline() async {
    //Create a new node in realtime data base and set this users status to online
    //With live location
    Geofire.initialize("onlineMechanics");
    Geofire.setLocation(currentFireBaseUser!.uid, userCurrentPosition!.latitude,
        userCurrentPosition!.longitude);

    //Set the Job status of mechanic to idle i.e searching for job
    DatabaseReference ref = db
        .ref()
        .child("users")
        .child(currentFireBaseUser!.uid)
        .child("mechanicInfo")
        .child("jobStatus");
    ref.set("idle");

    //Listen for change on job status
    ref.onValue.listen((event) {});

    //  Set isMechanicAvailable to true
    setState(() {
      isMechanicAvailable = true;
    });
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
    isMechanicAvailable = false;
    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }

  updateMechanicLocationAtRealtime() {
    //Listen For changes in users location
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentPosition = position;
      if (isMechanicAvailable) {
        Geofire.setLocation(currentFireBaseUser!.uid,
            userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      }
      // Now Update Location on Map too
      LatLng customerPos =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(customerPos));
    });
  }

//  Read Current Mechanic Info for notifications
  readCurrentMechanicsInfo() {
    currentFireBaseUser = fAuth.currentUser;

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }


//  Get Mechanic History
  getMechanicsAllRepairRequestsHistory() {
    List<String> requestKeys = [];

    db
        .ref()
        .child("repairRequest")
        .orderByChild("mechanic/mechanicId")
        .equalTo(currentFireBaseUser!.uid)
        .once()
        .then((data) {
      if (data.snapshot.value != null) {
        Map requestIds = data.snapshot.value as Map;
        //  List of requestIds
        requestIds.forEach((key, value) {
          requestKeys.add(key);
        });

        readAllRequestsDetails(requestKeys);
      }
    });
  }
}

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/model/directions_details.dart';
import 'package:mechaniconthego/model/repair_request_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_main.dart';
import 'package:mechaniconthego/widgets/charges_amount_dialog.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class MechanicToCustomer extends StatefulWidget {
  final RepairRequestModel customerRequest;

  const MechanicToCustomer({Key? key, required this.customerRequest})
      : super(key: key);

  @override
  State<MechanicToCustomer> createState() => _MechanicToCustomerState();
}

class _MechanicToCustomerState extends State<MechanicToCustomer> {
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  var geoLocator = Geolocator();

  //Default MAP Position Later changed to Current position of User
  final CameraPosition _userLoc = CameraPosition(
    target:
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude),
    zoom: 15,
  );

  String buttonTitle = "Arrived";

  Set<Marker> setOfMarkers = {};
  Set<Circle> setOfCircles = {};
  Set<Polyline> setOfPolyLine = {};
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  DirectionDetails? _directionDetails;

  BitmapDescriptor? mechanicOnTheGoMarker;

  var durationFromMechanicToCustomer = "";
  var distanceFromMechanicToCustomer = "";

  var cancelButtonVisibilityStatus = true;

  mechanicIconMarker() {
    if (mechanicOnTheGoMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(1, 1));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/mechanicIcon.png")
          .then((value) => mechanicOnTheGoMarker = value);
    }
  }

  @override
  void initState() {
    super.initState();
    saveMechanicsDataToRepairRequest();
  }

  @override
  void dispose() {
    newGoogleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mechanicIconMarker();
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Mechanic On The Go",
          style: pageHeadingText(),
        )),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(bottom: 250),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _userLoc,
            markers: setOfMarkers,
            circles: setOfCircles,
            polylines: setOfPolyLine,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
              newGoogleMapController = controller;
              // googleMapBlackTheme(newGoogleMapController);
              var mechanicCurrentLatLng = LatLng(userCurrentPosition!.latitude,
                  userCurrentPosition!.longitude);
              var customerLocationLatLng = LatLng(
                  widget.customerRequest.customerLocLat!,
                  widget.customerRequest.customerLocLng!);
              drawPolyLineRoutes(mechanicCurrentLatLng, customerLocationLatLng);
              getMechanicLocationUpdatesAtRealtime();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Customer Info
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.person,
                                color: iconColor,
                              ),
                              Text(
                                "${widget.customerRequest.customerName}",
                                style: whiteColorText(),
                              ),
                            ],
                          ),
                          //Phone
                          GestureDetector(
                            onTap: (){

                              final Uri url = Uri(
                                scheme: 'tel',
                                path: widget.customerRequest.customerPhone.toString(),
                              );
                              launchUrl(url);

                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.phone_android,
                                  color: iconColor,
                                ),
                                Text(
                                  "${widget.customerRequest.customerPhone}",
                                  style: whiteColorText(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 3,
                      thickness: 2,
                      color: Colors.white,
                    ),
                    //Customer Location
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: iconColor,
                          ),
                          SizedBox(
                            width: 270,
                            child: Text(
                              "${widget.customerRequest.customerLocationName}",
                              style: whiteColorText(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Distance and Duration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "$distanceFromMechanicToCustomer, ",
                          style: whiteColorText(),
                        ),
                        Text(
                          durationFromMechanicToCustomer,
                          style: whiteColorText(),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 3,
                      thickness: 2,
                      color: Colors.white,
                    ),
                    //  Vehicle Problem
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                MdiIcons.car,
                                color: iconColor,
                              ),
                              Text(
                                "${widget.customerRequest.vehicleInfo}",
                                style: whiteColorText(),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                MdiIcons.wrenchCog,
                                color: iconColor,
                              ),
                              Text(
                                "${widget.customerRequest.problem}",
                                style: whiteColorText(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 3,
                      thickness: 2,
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Visibility(
                          visible: cancelButtonVisibilityStatus,
                          child: ElevatedButton(
                            onPressed: () {
                              cancelTheRequest();
                            },
                            style: actionBtnWithRedColor(),
                            child: Text(
                              "Cancel",
                              style: whiteColorButtonText(),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (buttonTitle == "Arrived") {
                              //Update Status in Database
                              db
                                  .ref()
                                  .child("repairRequest")
                                  .child(widget.customerRequest.requestId!)
                                  .child("status")
                                  .set("Arrived");
                              setState(() {
                                buttonTitle = "Job Completed";
                                cancelButtonVisibilityStatus = false;
                              });
                            } else {
                              onJobCompletion();
                            }
                          },
                          style: actionBtnWithGreenColor(),
                          child: Text(
                            buttonTitle,
                            style: whiteColorButtonText(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getMechanicLocationUpdatesAtRealtime() {
    //Listen For changes in users location
    streamSubscriptionMechanicLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentPosition = position;
      // Now Update Location on Map too
      LatLng mechanicPos =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      Marker mechanicAnimatedMarker = Marker(
        markerId: const MarkerId("mechanicAnimatedMarker"),
        position: mechanicPos,
        icon: mechanicOnTheGoMarker!,
        infoWindow: const InfoWindow(title: "Your Location"),
      );

      setState(() {
        newGoogleMapController!
            .animateCamera(CameraUpdate.newLatLng(mechanicPos));
        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "mechanicAnimatedMarker");
        setOfMarkers.add(mechanicAnimatedMarker);
      });

      //Now Update Mechanic Location in repairRequest dataBase
      Map mechanicLocation = {
        "lat": userCurrentPosition!.latitude.toString(),
        "lng": userCurrentPosition!.longitude.toString()
      };
      db
          .ref()
          .child("repairRequest")
          .child(widget.customerRequest.requestId!)
          .child("mechanicLocation")
          .set(mechanicLocation);

      getDirectionDetails();
    });
  }

  //When Mechanic Accepts a request
  drawPolyLineRoutes(LatLng mechanicLocation, LatLng customerLocation) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            const ProgressDialog(message: "Loading"));

    var directionsDetailsInfo =
        await AssistantMethods.getDirectionsFromOriginToDestination(
            mechanicLocation, customerLocation);
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyPointsList =
        pPoints.decodePolyline(directionsDetailsInfo.encodedPoints);
    //Convert PointLatLng to Simple LatLng and Store it in
    //Make Sure previous Coordinate List is clear to get New One
    polyLinePositionCoordinates.clear();
    if (decodedPolyPointsList.isNotEmpty) {
      for (var pointLatLng in decodedPolyPointsList) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    //Make Sure previous Set is clear to get New One
    setOfPolyLine.clear();
    setState(() {
      //Design PolyLine
      Polyline polyline = Polyline(
        color: themeColor,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      setOfPolyLine.add(polyline);
    });

    //Set Markers for map
    Marker originMarker = Marker(
      markerId: const MarkerId("mechanicMarkerID"),
      position: mechanicLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId("customerMarkerID"),
      position: customerLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    //Set Circles for map
    Circle originCircle = Circle(
        circleId: const CircleId("mechanicCircleID"),
        fillColor: Colors.green,
        radius: 12,
        strokeColor: Colors.black,
        strokeWidth: 2,
        center: mechanicLocation);
    Circle destinationCircle = Circle(
        circleId: const CircleId("customerCircleID"),
        fillColor: Colors.red,
        radius: 12,
        strokeColor: Colors.black,
        strokeWidth: 2,
        center: customerLocation);

    setState(() {
      //  Update Marker and circle
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
      setOfCircles.add(originCircle);
      setOfCircles.add(destinationCircle);
    });
  }

  getDirectionDetails() async {
    if (userCurrentPosition == null) {
      return;
    }
    var mechanicCurrentLatLng =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    var customerLocationLatLng = LatLng(widget.customerRequest.customerLocLat!,
        widget.customerRequest.customerLocLng!);
    _directionDetails =
        await AssistantMethods.getDirectionsFromOriginToDestination(
            mechanicCurrentLatLng, customerLocationLatLng);

    if (_directionDetails != null) {
      durationFromMechanicToCustomer = _directionDetails!.durationText!;
      distanceFromMechanicToCustomer = _directionDetails!.distanceText!;
    }
  }

  saveMechanicsDataToRepairRequest() {
    Map mechanicLocation = {
      "lat": userCurrentPosition!.latitude,
      "lng": userCurrentPosition!.longitude,
    };

    DatabaseReference ref = db
        .ref()
        .child("repairRequest")
        .child(widget.customerRequest.requestId!);
    ref.child("status").set("accepted");
    ref.child("mechanicLocation").set(mechanicLocation);
    ref.child("mechanic").child("mechanicId").set(currentUserData!.id);
    ref.child("mechanic").child("mechanicName").set(currentUserData!.name);
    ref.child("mechanic").child("mechanicPhone").set(currentUserData!.phone);
    ref.child("mechanic").child("mechanicEmail").set(currentUserData!.email);
    ref.child("mechanic").child("mechanicRatings").set(currentUserData!.ratings);
    ref.child("mechanic").child("mechanicNoOfRatings").set(currentUserData!.noOfRatings);


    listenForUserEventForCancelOfRequest();
  }

  onJobCompletion() {
    showDialog(
        context: context,
        builder: (BuildContext context) => ChargesAmountDialog(
              repairRequest: widget.customerRequest,
            ));
  }

  cancelTheRequest() {
    try {
        db
            .ref()
            .child("repairRequest")
            .child(widget.customerRequest.requestId!)
            .remove()
            .then((value) {
          db
              .ref()
              .child("users")
              .child(currentFireBaseUser!.uid)
              .child("mechanicInfo")
              .child("jobStatus")
              .set("cancelling Request")
              .then((value) {
            Fluttertoast.showToast(
                msg: 'Request has been cancelled successfully',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MechanicMain()),
                (route) => false);
          });
        });
    } catch (error) {
      Fluttertoast.showToast(
          msg: 'Something Went Wrong During the cancellation',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  listenForUserEventForCancelOfRequest() {
    db
        .ref()
        .child("repairRequest")
        .child(widget.customerRequest.requestId!)
        .child("status")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        if (event.snapshot.value == "canceled") {
          Fluttertoast.showToast(
              msg: "Customer has cancelled the request",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

            db
                .ref()
                .child("repairRequest")
                .child(widget.customerRequest.requestId!)
                .remove()
                .then((value) {
              db
                  .ref()
                  .child("users")
                  .child(currentFireBaseUser!.uid)
                  .child("mechanicInfo")
                  .child("jobStatus")
                  .set("idle")
                  .then((value) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MechanicMain()),
                    (route) => false);
              });
            });
        }
      } else {
        return;
      }
    });
  }
}

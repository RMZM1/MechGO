import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/assistants/geo_fire_assistant.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/infoHandler/app_info.dart';
import 'package:mechaniconthego/main.dart';
import 'package:mechaniconthego/model/near_by_online_mechanics.dart';
import 'package:mechaniconthego/model/user_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/customer/near_by_online_mechanics_tab.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';
import 'package:mechaniconthego/widgets/user_payment_method_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});
  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain>
    with SingleTickerProviderStateMixin {
  //Scaffold Key is used for drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();

  GoogleMapController? newGoogleMapController;

  var geoLocator = Geolocator();

  //Default Camera Position
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15,
  );

  bool showNavigationDrawerButton = true;
  bool nearbyMechanicsListLoaded = false;
  TextEditingController vehicleInfoCtrl = TextEditingController();
  TextEditingController budgetCtrl = TextEditingController();

  List<String> problemsList = [
    "Battery",
    "Brakes",
    "Oil Change",
    "Puncture",
    "Head Lights",
    "Tail Lights",
    "Side Mirrors",
    "Suspension",
    "Tyre",
    "Other",
  ];
  String? selectedProblem;

  List<String> vehicleType = ["Car", "Bike"];
  String? selectedVehicleType;

  List<LatLng> polyLineCoordinateList = [];
  Set<Polyline> polyLineSet =
      {}; //this will set poly line on map according to coordinates given to it

  //To Set Origin and Destination Markers on map
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  BitmapDescriptor? onlineNearbyMechanicIcon;

  DatabaseReference? referenceRequest;

  var heightOfFindMechContainer = 380.0;
  var heightOfAssignedMechContainer = 0.0;
  var googleLogoPosition = 380.0;

  dynamic repairRequestStatus;
  var mechanicArrivalStatus = "Mechanic On The GO";
  var distanceLeft = "~Distance";
  var durationLeft = "~duration";
  var assignedMechanicName = "Mechanic Name";
  var assignedMechanicPhone = "Mechanic Phone";
  bool requestPosition = true;
  dynamic charges;
  dynamic fare;

  bool cancelButtonVisibility = true;
  //To get live location updates
  StreamSubscription<DatabaseEvent>? repairRequestInfoStreamSubscription;

  @override
  void initState() {
    super.initState();
    getCustomersAllRepairRequestsHistory();
    getUserRatings();
    Future.delayed(Duration.zero, () {
      drawPolyLineRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    createOnlineNearbyMechanicIconMarker();
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
      body: Stack(
        children: [
          //Google Map
          GoogleMap(
            padding: EdgeInsets.only(bottom: googleLogoPosition),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polyLineSet,
            markers: markerSet,
            circles: circleSet,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
              newGoogleMapController = controller;
              // googleMapBlackTheme(newGoogleMapController);
              //Update User Position
              locateUserPosition();
            },
          ),

          //  Custom Drawer Hamburger button

          Positioned(
            top: 36,
            left: 22,
            child: GestureDetector(
              onTap: () {
                //  It will open Drawer if showNavigationDrawerButton
                //else it will refresh
                if (showNavigationDrawerButton) {
                  _scaffoldKey.currentState!.openDrawer();
                } else {
                  polyLineCoordinateList.clear();
                  polyLineSet.clear();
                  markerSet.clear();
                  circleSet.clear();
                  directionDetailsInfo = null;
                  MyApp.restartApp(context);
                }
              },
              child: CircleAvatar(
                backgroundColor: themeColor,
                child: Icon(
                  showNavigationDrawerButton ? Icons.menu : Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          //  Search Mechanic
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: double.parse(heightOfFindMechContainer.toString()),
                decoration: const BoxDecoration(
                    color: themeColor,
                    // color: themeColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      /*
                      // Current Location Of User
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location,
                            color: iconColor,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Current Location",
                                  style: whiteColorText(),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    Provider.of<AppInformation>(context).userCurrentLocation !=
                                            null
                                        ? Provider.of<AppInformation>(context)
                                            .userCurrentLocation!
                                            .locationName!
                                        : "Not Getting Your Current Location",
                                    style: whiteColorText(),
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      */

                      // Vehicle Type Car, Bike
                      Row(
                        children: [
                          const Icon(
                            MdiIcons.car,
                            color: iconColor,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: DropdownButton2<String>(
                                  value: selectedVehicleType,
                                  isExpanded: true,
                                  style: whiteColorText(),
                                  underline: Container(),
                                  hint: Text(
                                    "Select Vehicle Type",
                                    style: whiteColorText(),
                                  ),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    iconSize: 32,
                                    iconEnabledColor: iconColor,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 250,
                                    width: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.black87,
                                    ),
                                    elevation: 20,
                                    offset: const Offset(40, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness:
                                          MaterialStateProperty.all<double>(10),
                                      thumbVisibility:
                                          MaterialStateProperty.all<bool>(true),
                                    ),
                                  ),
                                  items: vehicleType.map((vehicle) {
                                    return DropdownMenuItem(
                                      value: vehicle,
                                      child: Text(
                                        vehicle,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedVehicleType = newValue.toString();
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      //Vehicle Info
                      Row(
                        children: [
                          const Icon(
                            MdiIcons.car,
                            color: iconColor,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextField(
                                controller: vehicleInfoCtrl,
                                style: whiteColorText(),
                                decoration: InputDecoration(
                                  hintText: "Vehicle Name and Model",
                                  hintStyle: whiteColorText(),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      //Select Problem
                      Row(
                        children: [
                          const Icon(
                            Icons.car_repair,
                            color: iconColor,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: DropdownButton2<String>(
                                  value: selectedProblem,
                                  hint: Text(
                                    "Select Problem",
                                    style: whiteColorText(),
                                  ),
                                  isExpanded: true,
                                  style: whiteColorText(),
                                  underline: Container(),
                                  iconStyleData: const IconStyleData(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    iconSize: 32,
                                    iconEnabledColor: iconColor,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 250,
                                    width: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.black87,
                                    ),
                                    elevation: 20,
                                    offset: const Offset(40, 300),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness:
                                          MaterialStateProperty.all<double>(10),
                                      thumbVisibility:
                                          MaterialStateProperty.all<bool>(true),
                                    ),
                                  ),
                                  items: problemsList.map((problem) {
                                    return DropdownMenuItem(
                                      value: problem,
                                      child: Text(
                                        problem,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedProblem = newValue.toString();
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      //Customer Budget
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_exchange_rounded,
                            color: iconColor,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextField(
                                controller: budgetCtrl,
                                style: whiteColorText(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Enter your Budget in PKR",
                                  hintStyle: whiteColorText(),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // Find Mechanic Button
                      ElevatedButton(
                        onPressed: () async {
                          await validateInputFields();
                        },
                        style: actionBtnWithGreenColor(),
                        child: Text(
                          "Find Mechanic",
                          style: whiteColorButtonText(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //  Assigned Mechanic
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: double.parse(heightOfAssignedMechContainer.toString()),
                decoration: const BoxDecoration(
                    color: themeColor,
                    // color: themeColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      Text(
                        mechanicArrivalStatus,
                        style: whiteColorText(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      //Distance Time Left until arrival
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text(
                                distanceLeft,
                                style: whiteColorText(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text(
                                durationLeft,
                                style: whiteColorText(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      //Mechanic Name
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: iconColor,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text(
                                assignedMechanicName,
                                style: whiteColorText(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      //Phone
                      GestureDetector(
                        onTap: () {
                          final Uri url = Uri(
                            scheme: 'tel',
                            path: assignedMechanicPhone,
                          );
                          launchUrl(url);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_android_outlined,
                              color: iconColor,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Text(
                                  assignedMechanicPhone,
                                  style: whiteColorText(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: iconColor,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // Cancel Button
                      Visibility(
                        visible: cancelButtonVisibility,
                        child: ElevatedButton(
                          onPressed: () async {
                            //  Cancel The Request
                            cancelRequest();
                          },
                          style: actionBtnWithRedColor(),
                          child: Text(
                            "Cancel Request",
                            style: whiteColorButtonText(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  createOnlineNearbyMechanicIconMarker() {
    if (onlineNearbyMechanicIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(1, 1));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/mechanicIcon.png")
          .then((value) => onlineNearbyMechanicIcon = value);
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
    initializeGeoFireListener();
  }

  readAddress() async {
    await AssistantMethods.getHumanReadableAddress(
        userCurrentPosition!, context);
  }

  drawPolyLineRoutes() {
    //Get Encoded PolylinePoints
    var encodedPolyPoints = directionDetailsInfo != null
        ? directionDetailsInfo!.encodedPoints
        : null;
    if (encodedPolyPoints == null) {
      return;
    }
    else {
      //  Need to Decode the encoded poly points
      PolylinePoints pPoints = PolylinePoints();
      List<PointLatLng> decodedPolyPointsList =
          pPoints.decodePolyline(encodedPolyPoints);
      //Convert PointLatLng to Simple LatLng and Store it in
      //Make Sure previous Coordinate List is clear to get New One
      polyLineCoordinateList.clear();
      if (decodedPolyPointsList.isNotEmpty) {
        for (var pointLatLng in decodedPolyPointsList) {
          polyLineCoordinateList
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        }
      }
      //Make Sure previous Set is clear to get New One
      polyLineSet.clear();
      setState(() {
        //Set navigation Drawer Button to false to display cancel button
        showNavigationDrawerButton = false;
        //Hide Find Mechanic Button
        heightOfFindMechContainer = 0.0;
        //Also Set Google logo position on google maps
        googleLogoPosition = 0.0;
        //Design PolyLine
        Polyline polyline = Polyline(
          color: themeColor,
          polylineId: const PolylineId("PolylineID"),
          jointType: JointType.round,
          points: polyLineCoordinateList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        polyLineSet.add(polyline);
      });
      setMapMarkersAndCircles();
    }
  }

  setMapMarkersAndCircles() {
    //Get Origin Location Name
    var originName = Provider.of<AppInformation>(context, listen: false)
        .userCurrentLocation!
        .locationName!;
    //Get destination Location Name
    var destinationName = Provider.of<AppInformation>(context, listen: false)
        .userNextLocation!
        .locationName!;
    //Get CurrentPosition latitude and longitude
    var oLat = Provider.of<AppInformation>(context, listen: false)
        .userCurrentLocation!
        .locationLatitude!;
    var oLng = Provider.of<AppInformation>(context, listen: false)
        .userCurrentLocation!
        .locationLongitude!;
    //Get Destination latitude and longitude
    var dLat = Provider.of<AppInformation>(context, listen: false)
        .userNextLocation!
        .locationLatitude!;
    var dLng = Provider.of<AppInformation>(context, listen: false)
        .userNextLocation!
        .locationLongitude!;

    //Origin LatLng
    LatLng origin = LatLng(oLat, oLng);
    //Destination Latitude and longitude
    LatLng destination = LatLng(dLat, dLng);

    //Set Markers for map
    Marker originMarker = Marker(
      markerId: const MarkerId("originMarkerID"),
      infoWindow: InfoWindow(title: originName, snippet: "Origin"),
      position: origin,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationMarkerID"),
      infoWindow: InfoWindow(title: destinationName, snippet: "Destination"),
      position: destination,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    //Set Circles for map
    Circle originCircle = Circle(
        circleId: const CircleId("originCircleID"),
        fillColor: Colors.green,
        radius: 12,
        strokeColor: Colors.black,
        strokeWidth: 2,
        center: origin);
    Circle destinationCircle = Circle(
        circleId: const CircleId("destinationCircleID"),
        fillColor: Colors.red,
        radius: 12,
        strokeColor: Colors.black,
        strokeWidth: 2,
        center: destination);

    setState(() {
      //  Update Marker and circle
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  //Listen for Available mechanics
  initializeGeoFireListener() {
    //Get Online Mechanics
    Geofire.initialize("onlineMechanics");
    //Geofire.queryAtLocation(userCurrentPosition!.latitude,
    // userCurrentPosition!.longitude, radiusOfSearchingKM)
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered: //Online Mechanics
            //Get Nearby Mechanic
            NearByOnlineMechanics nearByOnlineMechanic =
                NearByOnlineMechanics();
            nearByOnlineMechanic.mechanicsId = map['key'];
            nearByOnlineMechanic.locationLatitude = map['latitude'];
            nearByOnlineMechanic.locationLongitude = map['longitude'];
            //Now Add it into the list
            GeoFireAssistant.updateNearbyMechanicsLocation(
                nearByOnlineMechanic);
            if (nearbyMechanicsListLoaded) {
              displayOnlineMechanicOnMap();
            }
            break;

          case Geofire.onKeyExited: //If online Mechanic become offline
            GeoFireAssistant.deleteMechanicFromList(map["key"]);
            break;

          //  When Mechanics Location change update it on customer map
          case Geofire.onKeyMoved:
            //Get Nearby Mechanic
            NearByOnlineMechanics nearByOnlineMechanic =
                NearByOnlineMechanics();
            nearByOnlineMechanic.mechanicsId = map['key'];
            nearByOnlineMechanic.locationLatitude = map['latitude'];
            nearByOnlineMechanic.locationLongitude = map['longitude'];
            //Now Update the list
            GeoFireAssistant.updateNearbyMechanicsLocation(
                nearByOnlineMechanic);
            displayOnlineMechanicOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyMechanicsListLoaded = true;
            // All Data is loaded
            //Display it
            displayOnlineMechanicOnMap();
            break;
        }
      }
      setState(() {});
    });
  }

  displayOnlineMechanicOnMap() {
    setState(() {
      for (NearByOnlineMechanics mechanic
          in GeoFireAssistant.nearByOnlineMechanicsList) {
        LatLng mechanicPosition =
            LatLng(mechanic.locationLatitude!, mechanic.locationLongitude!);
        //  Set Marker For mechanicPosition
        Marker marker = Marker(
          markerId: MarkerId(mechanic.mechanicsId!),
          position: mechanicPosition,
          infoWindow: const InfoWindow(title: "Mechanic", snippet: "Mechanic"),
          icon: onlineNearbyMechanicIcon!,
          rotation: 360,
        );
        markerSet.add(marker);
      }
    });
  }

  validateInputFields() {
    if (userCurrentPosition == null) {
      Fluttertoast.showToast(
          msg: "Could Not get your current location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (selectedVehicleType == null) {
      Fluttertoast.showToast(
          msg: "Please select your Vehicle Type",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (vehicleInfoCtrl.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please add your vehicle Info",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }else if(budgetCtrl.text.isEmpty){
      Fluttertoast.showToast(
          msg: "Please enter the budget",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    else if (selectedProblem == null) {
      Fluttertoast.showToast(
          msg: "Please select your problem",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      showDialog(
          context: context,
          barrierDismissible: false, //it should not disappear on user click
          builder: (BuildContext context) {
            return const ProgressDialog(message: "Processing! Please Wait ");
          });
      requestMechanic();
    }
  }

  //Display near By Mechanics
  requestMechanic() {
    //Save the Request Information
    referenceRequest = db.ref().child("repairRequest").push();
    var customerLocation =
        Provider.of<AppInformation>(context, listen: false).userCurrentLocation;
    Map customerLocationLatLngMap = {
      "latitude": customerLocation!.locationLatitude,
      "longitude": customerLocation.locationLongitude,
    };

    Map userInfo = {
      "id": currentUserData!.id,
      "name": currentUserData!.name,
      "phone": currentUserData!.phone,
      "email": currentUserData!.email,
      "ratings": currentUserData!.ratings,
      "noOfRatings": currentUserData!.noOfRatings,
    };
    Map mechanicInfo = {
      "mechanicId": "waiting",
      "mechanicName": "waiting",
      "mechanicPhone": "waiting",
      "mechanicEmail": "waiting",
      "mechanicRatings": "waiting",
      "mechanicNoOfRatings": "waiting",
    };
    Map requestInfo = {
      "time": DateTime.now().toString(),
      "customerLocation": customerLocationLatLngMap,
      "customerReadableAddress": customerLocation.locationName,
      "customer": userInfo,
      "problem": selectedProblem,
      "vehicleInfo": vehicleInfoCtrl.text.toString(),
      "mechanic": mechanicInfo,
      "customerBudget": budgetCtrl.text.toString(),
    };
    referenceRequest!.set(requestInfo);

    repairRequestInfoStreamSubscription =
        referenceRequest!.onValue.listen((event) {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value != null) {
        var map = event.snapshot.value as Map;
        setState(() {
          assignedMechanicName = map["mechanic"]["mechanicName"];
          assignedMechanicPhone = map["mechanic"]["mechanicPhone"];
          repairRequestStatus = map["status"];
        });
        if (map["status"] == "Arrived") {
          setState(() {
            cancelButtonVisibility = false;
            mechanicArrivalStatus = "Mechanic Has Arrived";
          });
        }
        if (map["mechanicLocation"] != null) {
          double mechanicLocationLat =
              double.parse(map["mechanicLocation"]["lat"].toString());
          double mechanicLocationLng =
              double.parse(map["mechanicLocation"]["lng"].toString());
          LatLng mechanicLocation =
              LatLng(mechanicLocationLat, mechanicLocationLng);

          var mechanicId = map["mechanic"]["mechanicId"];
          if (repairRequestStatus == "accepted") {
            updateArrivalDistanceDuration(mechanicLocation);
            updateMechanicMarkers(mechanicLocation, mechanicId);
          }
        }
        if (map["status"] == "Completed") {
          if (map["fareAmount"] != null) {
            setState(() {
              fare = map["fareAmount"];
            });
          }
          if (map["charges"] != null) {
            setState(() {
              charges = map["charges"];
            });
          }
          showDialog(
            context: context,
            builder: (BuildContext context) => PaymentMethodDialog(
              fareAmount: fare.toString(),
              charges: charges.toString(),
              userId: map["mechanic"]["mechanicId"],
              requestId: referenceRequest!.key!,
            ),
          );

          referenceRequest!.onDisconnect();
          repairRequestInfoStreamSubscription!.cancel();
        }
      }
    });

    //Get Near by mechanics
    searchNearestOnlineMechanics();
  }

  searchNearestOnlineMechanics() async {
    if (GeoFireAssistant.nearByOnlineMechanicsList.isEmpty) {
      // NO Available Mechanics
      //  Delete request information
      referenceRequest!.remove();
      setState(() {
        markerSet.clear();
        circleSet.clear();
        polyLineSet.clear();
        polyLineCoordinateList.clear();
      });

      Fluttertoast.showToast(
          msg: "Could not find any mechanic in your area",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      db.ref().child("repairRequest").child(referenceRequest!.key!).remove();
      Navigator.pop(context);
      return;
    } else {
      await retrieveOnlineMechanicInformation(
          GeoFireAssistant.nearByOnlineMechanicsList);

      goToMechanicScreen();
    }
  }

  retrieveOnlineMechanicInformation(List availableMechanicsList) async {
    mechanicList.clear();
    DatabaseReference ref = db.ref().child('users');
    for (int i = 0; i < availableMechanicsList.length; i++) {
      await ref
          .child(availableMechanicsList[i].mechanicsId.toString())
          .once()
          .then((data) {
        var mechanicInfoKey = data.snapshot;
        var mechanic = UserModel.fromSnapshot(mechanicInfoKey);
        if (mechanic.mechanicInfo["mechanicType"] ==
                "$selectedVehicleType Mechanic" &&
            mechanic.mechanicInfo["jobStatus"] == "idle") {
          mechanicList.add(mechanic);
        }
      });
    }
  }

  goToMechanicScreen() async {
    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NearByOnlineMechanicsScreen(
                  selectedProblem: '$selectedProblem',
                  referenceRequest: referenceRequest!,
                )));

    if (response == "mechanicChosen") {
      db.ref().child("users").child(chosenMechanicId).once().then((data) {
        if (data.snapshot.value != null) {
          //  Notify Mechanic
          sendNotificationToMechanic(chosenMechanicId);

          //  Response from Mechanic
          db
              .ref()
              .child("users")
              .child(chosenMechanicId)
              .child("mechanicInfo")
              .child("jobStatus")
              .onValue
              .listen((event) {
            //  If Mechanic Accepted
            //  The Job Status of Mechanic is accepted
            if (event.snapshot.value == "accepted") {
              showUIWhenMechanicAcceptsTheRequest();
              Navigator.pop(context);
            }
            //  If Mechanic Rejected
            //  If Job Status of mechanic is idle
            if (event.snapshot.value == "cancelling Request") {
              Fluttertoast.showToast(
                  msg:
                      "Mechanic Cancelled your request please choose another mechanic",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);

              db
                  .ref()
                  .child("users")
                  .child(chosenMechanicId)
                  .child("mechanicInfo")
                  .child("jobStatus")
                  .set("idle");

              showUIWhenMechanicRejectsTheRequest();
              //Remove the progress loading dialog
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerMain()),
                  (route) => false);
            }
          });
        } else {
          Fluttertoast.showToast(
              msg: "Mechanic went Offline Please Try again",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    }
  }

  sendNotificationToMechanic(String id) {
    //Update Fare for repairRequest
    db
        .ref()
        .child("repairRequest")
        .child(referenceRequest!.key!)
        .child("fareAmount")
        .set(fareAmountForChosenMechanic);

    //Update chosen mechanic Job status
    db
        .ref()
        .child("users")
        .child(chosenMechanicId)
        .child("mechanicInfo")
        .child("jobStatus")
        .set(referenceRequest!.key);

    //  Automate Push Notification
    db
        .ref()
        .child("users")
        .child(chosenMechanicId)
        .child("mechanicInfo")
        .child("messageToken")
        .once()
        .then((data) {
      if (data.snapshot.value != null) {
        String msgToken = data.snapshot.value.toString();
        //  Send Notification
        AssistantMethods.sendNotificationToMechanic(
            msgToken, referenceRequest!.key.toString());
      } else {
        Fluttertoast.showToast(
            msg: "This Mechanic is Not Available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      Future.delayed(const Duration(seconds: 120), () {
        checkForRequestStatus();
      });
    });
  }

  //This will automatically cancel request if there is no response from mechanic
  checkForRequestStatus() {
    db
        .ref()
        .child("users")
        .child(chosenMechanicId)
        .child("mechanicInfo")
        .child("jobStatus")
        .once()
        .then((data) {
      if (data.snapshot.value != null) {
        if (data.snapshot.value.toString() ==
            referenceRequest!.key.toString()) {
          db
              .ref()
              .child("users")
              .child(chosenMechanicId)
              .child("mechanicInfo")
              .child("jobStatus")
              .set("cancelling Request");
        }
      }
    });
  }

  showUIWhenMechanicAcceptsTheRequest() {
    setState(() {
      heightOfFindMechContainer = 0.0;
      heightOfAssignedMechContainer = 250.0;
    });
  }

  showUIWhenMechanicRejectsTheRequest() {
    setState(() {
      heightOfFindMechContainer = 380.0;
      heightOfAssignedMechContainer = 0.0;
    });
  }

  updateArrivalDistanceDuration(mechanicLocation) async {
    if (requestPosition == true) {
      requestPosition = false;
      LatLng customerCurrentPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo =
          await AssistantMethods.getDirectionsFromOriginToDestination(
              mechanicLocation, customerCurrentPosition);

      if (directionDetailsInfo == null) {
        return;
      } else {
        setState(() {
          durationLeft = directionDetailsInfo.durationText.toString();
          distanceLeft = directionDetailsInfo.distanceText.toString();
        });
      }
      requestPosition = false;
    }
  }

  cancelRequest() {
    db
        .ref()
        .child("repairRequest")
        .child(referenceRequest!.key!)
        .child("status")
        .set("canceled");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerMain()),
        (route) => false);
  }

  //  Get All the Repair Requests (History) of customer
  getCustomersAllRepairRequestsHistory() {
    List<String> requestKeys = [];

    db
        .ref()
        .child("repairRequest")
        .orderByChild("customer/id")
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

  updateMechanicMarkers(mechanicPosition, mechanicsId) {
    Marker mechanicAnimatedMarker = Marker(
      markerId: MarkerId(mechanicsId),
      position: mechanicPosition,
      infoWindow: const InfoWindow(title: "Mechanic", snippet: "Mechanic"),
      icon: onlineNearbyMechanicIcon!,
      rotation: 360,
    );
    setState(() {
      markerSet.clear();
      markerSet.removeWhere((element) => element.markerId.value == mechanicsId);
      markerSet.add(mechanicAnimatedMarker);
    });
  }
}

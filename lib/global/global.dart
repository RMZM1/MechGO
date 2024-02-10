import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechaniconthego/infoHandler/app_info.dart';
import 'package:mechaniconthego/model/direction_model.dart';
import 'package:mechaniconthego/model/directions_details.dart';
import 'package:mechaniconthego/model/rating_model.dart';
import 'package:mechaniconthego/model/repair_request_model.dart';
import 'package:mechaniconthego/model/user_model.dart';
import 'package:provider/provider.dart';

//FireBase Authentication instance
final FirebaseAuth fAuth = FirebaseAuth.instance;
//Realtime database instance
final FirebaseDatabase db = FirebaseDatabase.instance;

//Below Variables to check who is logged in i.e mechanic or client
User? currentFireBaseUser;
//variable to store Current User Data
UserModel? currentUserData;

//Offline and online status of mechanic
//Default its offline
bool isMechanicAvailable = false; //Offline

//Current Location of User
Position? userCurrentPosition;

LocationPermission? _locationPermission;

//Directions from Origin to Hotel or Pump
DirectionDetails? directionDetailsInfo;

//To Update mechanics location and get Live Location
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionMechanicLivePosition;

List<UserModel> mechanicList = []; //Mechanic keys info list

//Chosen Mechanic From MechanicList
String chosenMechanicId = "";
dynamic fareAmountForChosenMechanic = 0;

List<RepairRequestModel> requestHistory = [];
List<Ratings> allRatings = [];


Future<bool> checkIfEmailAlreadyInUse(String emailAddress) async {
  // Fetch sign-in methods for the email address
  final emailList = await fAuth.fetchSignInMethodsForEmail(emailAddress);

  // In case list is not empty
  if (emailList.isNotEmpty) {
    // Return true because there is an existing
    // user using the email address
    return true;
  } else {
    // Return false because email address is not in use
    return false;
  }
}

Future<bool> checkIfPhoneAlreadyInUse(String phoneNumber) async {
  bool isNumberRegistered = false;
  await db.ref().child("registeredPhoneNumbers").once().then((data) {
    for (var i in data.snapshot.children) {
      String data = i.child("phoneNumber").value.toString();

      if (phoneNumber == data) {
        isNumberRegistered = true;
        return isNumberRegistered;
      } else {
        isNumberRegistered = false;
      }
    }
  });
  return isNumberRegistered;
}

Future<bool> checkIfCNICAlreadyInUse(String cnic) async {
  bool isCNICRegistered = false;
  await db.ref().child("registeredCNIC").once().then((data) {
    for (var i in data.snapshot.children) {
      String data = i.child("cnic").value.toString();
      // if data is equal to cnic than the given cnic is registered
      if (cnic == data) {
        isCNICRegistered = true;
        return isCNICRegistered;
      } else {
        isCNICRegistered = false;
      }
    }
  });
  return isCNICRegistered;
}

checkLocationPermissionAllowed() async {
  _locationPermission = await Geolocator.requestPermission();
  if (_locationPermission == LocationPermission.denied) {
    _locationPermission = await Geolocator.requestPermission();
  }
}

Future<bool> getNextLocation(
    String placeId, String name, double lat, double lng, context) async {
  DirectionModel directions = DirectionModel();
  directions.locationName = name;
  directions.locationLatitude = lat;
  directions.locationLongitude = lng;
  directions.placeId = placeId;

  Provider.of<AppInformation>(context, listen: false)
      .updateUserNextLocation(directions);

  return true;
}


readAllRequestsDetails(List<String> requestKeys) {
  requestHistory.clear();
  for (String key in requestKeys) {
    db.ref().child("repairRequest").child(key).once().then((data) {
      if (data.snapshot.value != null) {
        if((data.snapshot.value as Map)["status"]=="Finished" || (data.snapshot.value as Map)["status"]=="Completed"){
          var history = RepairRequestModel.fromSnapshot(data.snapshot);
          requestHistory.add(history);
        }
      }
    });
  }
}


//Get Users Feedback and ratings

getUserRatings() async {
  List<String> keys = [];

  var data = await db
      .ref()
      .child("users")
      .child(fAuth.currentUser!.uid)
      .child("feedback")
      .once();

  if (data.snapshot.value != null) {
    Map ids = data.snapshot.value as Map;

    ids.forEach((key, value) {
      keys.add(key);
    });

    await readRatings(keys);
  }
}

readRatings(List<String> keys) async {
  allRatings.clear();

  await Future.wait(keys.map((key) async {
    var data = await db
        .ref()
        .child("users")
        .child(currentUserData!.id!)
        .child("feedback")
        .child(key)
        .once();

    if (data.snapshot.value != null) {
      var rating = Ratings.fromSnapshot(data.snapshot);
      allRatings.add(rating);
    }
  }));
}
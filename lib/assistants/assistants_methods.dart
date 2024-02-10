import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/global/keys.dart';
import 'package:mechaniconthego/infoHandler/app_info.dart';
import 'package:mechaniconthego/model/direction_model.dart';
import 'package:mechaniconthego/model/directions_details.dart';
import 'package:mechaniconthego/model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AssistantMethods {
  //To Read data of current user and store it in an object of user model class
  static void readCurrentUserInfo() async {
    currentFireBaseUser = fAuth.currentUser;

    DatabaseReference userRef =
        db.ref().child("users").child(currentFireBaseUser!.uid);

    await userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        currentUserData = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  // Get URL and convert it in to human readable address
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.post(Uri.parse(url));

    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body; //In form of JSON
        var decodeResponseData = jsonDecode(responseData);
        return decodeResponseData;
      } else {
        return "An Error Occurred";
      }
    } catch (exp) {
      return "An Error Occurred";
    }
  }

  // Get Latitude and longitude and convert them in human readable address
  static Future<dynamic> getHumanReadableAddress(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mobileMapKey";
    String address = "";
    var requestResponse = await receiveRequest(apiUrl);
    if (requestResponse != "An Error Occurred") {
      address = requestResponse["results"][0]
          ["formatted_address"]; //As in documentation of GeoCoding (Reverse)

      DirectionModel currentLocation = DirectionModel();
      currentLocation.locationLatitude = position.latitude;
      currentLocation.locationLongitude = position.longitude;
      currentLocation.locationName = address;

      Provider.of<AppInformation>(context, listen: false)
          .updateUserCurrentLocation(currentLocation);
    }
    return address;
  }

  static Future<dynamic> getDirectionsFromOriginToDestination(
      LatLng originPosition, LatLng destinationPosition) async {
    String directionsFromOriginToDestinationUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mobileMapKey";

    var responseDirections =
        await receiveRequest(directionsFromOriginToDestinationUrl);
    if (responseDirections == "An Error Occurred") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =
        responseDirections["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceValue =
        responseDirections["routes"][0]["legs"][0]["distance"]["value"];
    directionDetails.distanceText =
        responseDirections["routes"][0]["legs"][0]["distance"]["text"];

    directionDetails.durationValue =
        responseDirections["routes"][0]["legs"][0]["duration"]["value"];
    directionDetails.durationText =
        responseDirections["routes"][0]["legs"][0]["duration"]["text"];

    return directionDetails;
  }

  static dynamic getFareAmount(DirectionDetails details) {
    //Fuel Price / Ltr in PKR
    double fuelPrice = 300.00;
    //Average distance traveled by a common vehicle / Ltr in KM
    double avgDistance = 40;
    //averagePrice per km
    double avgPrice = fuelPrice / avgDistance;

    //In PKR
    double farePerMin = 10;
    double farePerKm = avgPrice;
    double farePerTime = (details.durationValue / 60) * farePerMin;
    double farePerDistance = (details.distanceValue / 1000) * farePerKm;
    double totalFare = farePerTime + farePerDistance;

    return totalFare.toInt();
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFireBaseUser!.uid);
  }

  static resumeLiveLocationUpdates() {
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(currentFireBaseUser!.uid, userCurrentPosition!.latitude,
        userCurrentPosition!.longitude);
  }

  static sendNotificationToMechanic(
      String msgToken, String repairRequestId) async {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": cloudMessagingServerKey
    };
    Map bodyNotification = {
      "body": "MechGo, New Repair Request",
      "title": "MechGO"
    };
    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "repairRequestId": repairRequestId
    };

    Map notificationFormat = {
      "notification": bodyNotification,
      "priority": "high",
      "data": dataMap,
      "to": msgToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: header,
      body: jsonEncode(notificationFormat),
    );
  }
}

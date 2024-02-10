import 'package:flutter/material.dart';
import 'package:mechaniconthego/model/direction_model.dart';

class AppInformation extends ChangeNotifier {
  //Next location is for finding hotel or finding Gas Stations
  DirectionModel? userCurrentLocation, userNextLocation;

  void updateUserCurrentLocation(DirectionModel currentLocation) {
    userCurrentLocation = currentLocation;
    notifyListeners();
  }

  void updateUserNextLocation(DirectionModel nextLocation) {
    userNextLocation = nextLocation;
    notifyListeners();
  }
}

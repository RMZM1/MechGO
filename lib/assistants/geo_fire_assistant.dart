import 'package:mechaniconthego/model/near_by_online_mechanics.dart';

class GeoFireAssistant {
  static List<NearByOnlineMechanics> nearByOnlineMechanicsList = [];

  static void deleteMechanicFromList(String mechanicId) {
    int indexNumber = nearByOnlineMechanicsList
        .indexWhere((element) => element.mechanicsId == mechanicId);
    nearByOnlineMechanicsList.removeAt(indexNumber);
  }

  static void updateNearbyMechanicsLocation(
      NearByOnlineMechanics nearByOnlineMechanic) {
    //if it does not contains element than add else update
    bool result = checkMechanicExistInList(nearByOnlineMechanic);
    if (!result) {
      nearByOnlineMechanicsList.add(nearByOnlineMechanic);
    } else {
      int indexNumber = nearByOnlineMechanicsList.indexWhere(
          (element) => element.mechanicsId == nearByOnlineMechanic.mechanicsId);

      nearByOnlineMechanicsList[indexNumber].locationLatitude =
          nearByOnlineMechanic.locationLatitude;
      nearByOnlineMechanicsList[indexNumber].locationLongitude =
          nearByOnlineMechanic.locationLongitude;
    }
  }

  static bool checkMechanicExistInList(
      NearByOnlineMechanics nearByOnlineMechanic) {
    bool result = false;
    for (NearByOnlineMechanics mechanic in nearByOnlineMechanicsList) {
      if (mechanic.mechanicsId == nearByOnlineMechanic.mechanicsId) {
        //Mechanic Already added in list
        result = true;
        return result;
      }
    }
    return result;
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/model/repair_request_model.dart';
import 'package:mechaniconthego/notifications/notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //  1. Terminated State
    //  When the device is locked or the application is not running.
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //  Display Repair Request Info
        readRepairRequestInfo(remoteMessage.data["repairRequestId"], context);
      }
    });

    //  2. Foreground State
    //  When the application is open, in view & in use.
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      //  Display Repair Request Info
      readRepairRequestInfo(remoteMessage!.data["repairRequestId"], context);
    });

    //  3. Background State
    //  When the application is open, however in the background (minimised).

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      //  Display Repair Request Info
      readRepairRequestInfo(remoteMessage!.data["repairRequestId"], context);
    });
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    db
        .ref()
        .child("users")
        .child(currentFireBaseUser!.uid)
        .child("mechanicInfo")
        .child("messageToken")
        .set(registrationToken);
    messaging.subscribeToTopic("mechanics");
    messaging.subscribeToTopic("customers");
  }

  readRepairRequestInfo(String repairRequestId, BuildContext context) async {
    //  get All ride request and search the given one
    await db
        .ref()
        .child("repairRequest")
        .child(repairRequestId)
        .once()
        .then((data) {
          if(data.snapshot.value != null){
            var req = data.snapshot.value as Map;
            RepairRequestModel repairRequestInfo = RepairRequestModel();
            repairRequestInfo.requestId = data.snapshot.key.toString();
            repairRequestInfo.customerLocLat = double.parse(req["customerLocation"]["latitude"].toString());
            repairRequestInfo.customerLocLng = double.parse(req["customerLocation"]["longitude"].toString());
            repairRequestInfo.customerLocationName = req["customerReadableAddress"];
            repairRequestInfo.problem = req["problem"];
            repairRequestInfo.fareAmount = req["fareAmount"];
            repairRequestInfo.vehicleInfo = req["vehicleInfo"];
            repairRequestInfo.customerId = req["customer"]["id"];
            repairRequestInfo.customerName = req["customer"]["name"];
            repairRequestInfo.customerPhone = req["customer"]["phone"];
            repairRequestInfo.customerRatings = req["customer"]["ratings"];
            repairRequestInfo.customerNoOfRatings = req["customer"]["noOfRatings"];
            repairRequestInfo.customerBudget = req["customerBudget"];

            //  pass repairRequest to NotificationBox
            showDialog(
                context: context,
                builder: (BuildContext context)=>NotificationDialogBox(
                  repairRequestInfo: repairRequestInfo,
                ),
            );
          }
          else{
            Fluttertoast.showToast(
                msg: "This Request has been deleted",
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

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/model/repair_request_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_to_customer.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDialogBox extends StatefulWidget {
  final RepairRequestModel repairRequestInfo;
  const NotificationDialogBox({Key? key, required this.repairRequestInfo})
      : super(key: key);

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.black,
      elevation: 2,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: themeColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 15,
            ),
            Text("New Repair Request", style: pageHeadingText()),
            const Divider(
              height: 3,
              thickness: 3,
              color: Colors.white,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Customer Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.person,
                      color: iconColor,
                      size: 54,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.repairRequestInfo.customerName}",
                          style: whiteColorText(),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${widget.repairRequestInfo.customerPhone}",
                          style: whiteColorText(),
                        ),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: double.parse(widget
                                  .repairRequestInfo.customerRatings
                                  .toString()),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${widget.repairRequestInfo.customerNoOfRatings}",
                                style: whiteColorText(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                //Location
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                      width: 200,
                      child: Text(
                        "Location: ${widget.repairRequestInfo.customerLocationName}",
                        style: whiteColorText(),
                      )),
                ),
                //Vehicle Info
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                      width: 200,
                      child: Text(
                        "Vehicle: ${widget.repairRequestInfo.vehicleInfo}",
                        style: whiteColorText(),
                      )),
                ),
                //Problem
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                      width: 200,
                      child: Text(
                          "Problem: ${widget.repairRequestInfo.problem}",
                          style: whiteColorText())),
                ),

                //Customers Budget
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                      width: 200,
                      child: Text(
                          "Customer Budget: ${widget.repairRequestInfo.customerBudget} PKR",
                          style: whiteColorText())),
                ),


                //Divider
                const Divider(
                  thickness: 3,
                  height: 3,
                  color: Colors.white,
                ),
                //Accept/reject buttons
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            //  Cancel/Reject The Request
                            rejectRequest();
                          },
                          style: actionBtnWithRedColor(),
                          child: Text(
                            "Reject",
                            style: whiteColorButtonText(),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            //  Call The Client
                            callClient();
                          },
                          style: actionBtnWithGreenColor(),
                          child: Text(
                            "Call",
                            style: whiteColorButtonText(),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            //  Accept The Request
                            acceptRequest(context);
                          },
                          style: actionBtnWithGreenColor(),
                          child: Text(
                            "Accept",
                            style: whiteColorButtonText(),
                          )),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  acceptRequest(BuildContext context) {
    var repairRequestId = "";
    db
        .ref()
        .child("users")
        .child(currentFireBaseUser!.uid)
        .child("mechanicInfo")
        .child("jobStatus")
        .once()
        .then((data) {
      if (data.snapshot.value != null) {
        repairRequestId = data.snapshot.value.toString();
        if (repairRequestId == widget.repairRequestInfo.requestId) {
          db
              .ref()
              .child("users")
              .child(currentFireBaseUser!.uid)
              .child("mechanicInfo")
              .child("jobStatus")
              .set("accepted");

          //  Show routes from mechanic to customer
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MechanicToCustomer(
                      customerRequest: widget.repairRequestInfo)),
              (route) => false);
        } else {
          Fluttertoast.showToast(
              msg: "The Request has been cancelled",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "The Request has been cancelled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  rejectRequest() {
    try {
      db
          .ref()
          .child("repairRequest")
          .child(widget.repairRequestInfo.requestId!)
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
            Navigator.pop(context);
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

  callClient(){
    final Uri url = Uri(
      scheme: 'tel',
      path: widget.repairRequestInfo.customerPhone,
    );
    launchUrl(url);
  }
}

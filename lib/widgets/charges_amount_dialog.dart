import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/model/repair_request_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/update/give_ratings.dart';

class ChargesAmountDialog extends StatefulWidget {
  final RepairRequestModel repairRequest;
  const ChargesAmountDialog({Key? key, required this.repairRequest}) : super(key: key);

  @override
  State<ChargesAmountDialog> createState() => _ChargesAmountDialogState();
}

class _ChargesAmountDialogState extends State<ChargesAmountDialog> {

  TextEditingController chargesCtrl = TextEditingController();
  dynamic total = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Collect The Charges from the customer",
                  style: whiteColorText(),
                ),
              ],
            ),
            const SizedBox(height: 8,),
            const Divider(
              height: 3,
              thickness: 3,
              color: iconColor,
            ),
            const SizedBox(height: 8,),
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Fare Amount: ${widget.repairRequest.fareAmount}Rs",
                style: whiteColorText()
              ),
            ),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: chargesCtrl,
                keyboardType: TextInputType.number,
                style: whiteColorText(),
                decoration: textFieldsDec().copyWith(
                    hintText: "Enter Your Charges in Rs",
                ),
                onChanged: (value){
                  setState(() {
                    total = int.parse(widget.repairRequest.fareAmount.toString()) + int.parse(value.toString());
                  });
                },
              ),
            ),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                style: actionBtnWithGreenColor(),
                onPressed: () {
                  saveChargesToRepairRequest();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Collect Cash",
                      style: whiteColorButtonText()
                    ),
                    Text(
                      "PKR ${total.toString()}",
                      style: whiteColorButtonText(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  saveChargesToRepairRequest(){
    if(chargesCtrl.text.isNotEmpty){
      DatabaseReference ref = db.ref().child("repairRequest").child(widget.repairRequest.requestId!);
      ref.child("charges").set(chargesCtrl.text.toString());
      ref.child("totalCharges").set(total.toString());
      ref.child("status").set("Completed");

      DatabaseReference mech = db.ref().child("users").child(currentFireBaseUser!.uid);
      mech.child("totalEarnings").once().then(
              (data){
                if(data.snapshot.value != null){
                  var earnings = int.parse(data.snapshot.value.toString()) + int.parse(total.toString());
                  mech.child("totalEarnings").set(earnings.toString());
                }
                else{
                  mech.child("totalEarnings").set(total.toString());
                }
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context)=>GiveRatings(userId: widget.repairRequest.customerId!, requestId: widget.repairRequest.requestId!,)),
                        (route) => false);
              });

    }
    else{
      Fluttertoast.showToast(
          msg: 'Please Enter Your Charges for the Job',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/customer/online_payment.dart';
import 'package:mechaniconthego/users/update/give_ratings.dart';

class PaymentMethodDialog extends StatefulWidget {
  final String fareAmount;
  final String charges;
  final String userId; //mech id is passed
  final String requestId;
  const PaymentMethodDialog(
      {Key? key,
      required this.fareAmount,
      required this.charges,
      required this.userId,
      required this.requestId})
      : super(key: key);

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  var total;
  String selectedMethod = "Cash";
  @override
  void initState() {
    total = double.parse(widget.charges.toString()) +
        double.parse(widget.fareAmount.toString());
    super.initState();
  }

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
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: Text("Fare Amount: ${widget.fareAmount} Rs",
                  style: whiteColorText()),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "charges: ${widget.charges} Rs",
                style: whiteColorText(),
              ),
            ),
            const SizedBox(
              height: 8,
            ),

            //Select Payment Method
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Select Payment Method",
                style: whiteColorText(),
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: RadioListTile(
                  value: "Cash",
                  groupValue: selectedMethod,
                  activeColor: Colors.white,
                  title: Text(
                    "Cash",
                    style: whiteColorText(),
                  ),
                  onChanged: (value) => setState(() {
                        selectedMethod = value!;
                      })),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: RadioListTile(
                  value: "Online",
                  groupValue: selectedMethod,
                  activeColor: Colors.white,
                  title: Text(
                    "Online",
                    style: whiteColorText(),
                  ),
                  onChanged: (value) => setState(() {
                        selectedMethod = value!;
                      })),
            ),

            const SizedBox(
              height: 8,
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ElevatedButton(
                style: actionBtnWithGreenColor(),
                onPressed: () {
                  //  Move To Ratings or online Payment
                  goTo();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pay Cash", style: whiteColorButtonText()),
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

  goTo() {
    if (selectedMethod == "Cash") {
      db
          .ref()
          .child("repairRequest")
          .child(widget.requestId)
          .child("paymentMethod")
          .set("cash");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => GiveRatings(
                    userId: widget.userId,
                    requestId: widget.requestId,
                  )),
          (route) => false);
    }
    if (selectedMethod == "Online") {
      db
          .ref()
          .child("users")
          .child(widget.userId)
          .child("stripeOnBoardingComplete")
          .once()
          .then((data) {
        if (data.snapshot.value == true) {
          if(total < 200){
            Fluttertoast.showToast(
                msg: "For online payment amount must be greater than 200",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          else{
            db
                .ref()
                .child("repairRequest")
                .child(widget.requestId)
                .child("paymentMethod")
                .set("online");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => OnlinePayment(
                      charges: total.toString(),
                      mechId: widget.userId,
                      requestId: widget.requestId,
                    )),
                    (route) => false);
          }
        }
        else{
          Fluttertoast.showToast(
              msg: "Mechanic Does not have online bank Account Connected",
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
}

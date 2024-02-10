import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/assistants/stripe_backend_assistant.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/customer/checkout.dart';
import 'package:mechaniconthego/users/update/give_ratings.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class OnlinePayment extends StatefulWidget {
  final String charges;
  final String mechId;
  final String requestId;

  const OnlinePayment(
      {Key? key,
      required this.charges,
      required this.mechId,
      required this.requestId})
      : super(key: key);

  @override
  State<OnlinePayment> createState() => _OnlinePaymentState();
}

class _OnlinePaymentState extends State<OnlinePayment> {
  String selectedMethod = "Card";
  Map<String, dynamic>? paymentIntentData;
  String? mechStripeAccountId;
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () => checkForMechStripeAccountId());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Mechanic On The Go",
          style: pageHeadingText(),
        )),
        automaticallyImplyLeading:
            false, // this will hide Drawer hamburger icon
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          //  Heading
          Center(
              child: Text(
            'Payment',
            style: mainHeadingText(),
          )),

          // Select Payment Methods
          Container(
            margin: const EdgeInsets.fromLTRB(8.0, 10, 8.0, 0),
            padding: const EdgeInsets.fromLTRB(8.0, 10, 8.0, 0),
            child: RadioListTile(
                value: "Card",
                groupValue: selectedMethod,
                activeColor: Colors.cyan,
                title: Text(
                  "Pay with Credit/Debit Card",
                  style: greyColorText(),
                ),
                onChanged: (value) => setState(() {
                      selectedMethod = value!;
                    })),
          ),

          //  Pay Button
          Center(
            child: ElevatedButton(
              style: actionBtnWithGreenColor(),
              onPressed: () {
                startPayment();
              },
              child: Text(
                "Pay ${widget.charges} PKR",
                style: whiteColorButtonText(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> checkForMechStripeAccountId() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Processing! Please Wait ");
        });
    await db
        .ref()
        .child("users")
        .child(widget.mechId)
        .child("stripeOnBoardingComplete")
        .once()
        .then((d) {
      if (d.snapshot.value != null && d.snapshot.value == true) {
        db
            .ref()
            .child("users")
            .child(widget.mechId)
            .child("stripeAccountId")
            .once()
            .then((data) {
          if (data.snapshot.value != null) {
            mechStripeAccountId = data.snapshot.value.toString();
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg:
                    "Could not get mechanic online account please proceed with the cash",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        });
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg:
                "ON BOARDING ERROR:Could not get mechanic online account please proceed with the cash",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }).catchError((error) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Could not process online Payment please proceed with the cash",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  Future<void> startPayment() async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false, //it should not disappear on user click
          builder: (BuildContext context) {
            return const ProgressDialog(message: "Processing! Please Wait ");
          });

      double amount = double.parse(widget.charges);

      CheckoutSessionResponse response =
          await StripeBackendService.payOnline(mechStripeAccountId!, amount);
      String sessionId = response.session['id'];
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (_) => CheckoutPage(sessionId: sessionId),
        ))
            .then((value) {
          if (value == 'success') {
            Fluttertoast.showToast(
                msg: "Payment Successful",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => GiveRatings(
                        userId: widget.mechId, requestId: widget.requestId)),
                (route) => false);
          } else if (value == 'cancel') {
            Fluttertoast.showToast(
                msg: "Payment Failed or Cancelled",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        });
      });
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "An Error Occurred Please Proceed With the Cash",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

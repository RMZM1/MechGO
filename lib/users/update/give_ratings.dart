import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/styles/styles.dart';

class GiveRatings extends StatefulWidget {
  final String userId;
  final String requestId;
  const GiveRatings({Key? key, required this.userId, required this.requestId})
      : super(key: key);

  @override
  State<GiveRatings> createState() => _GiveRatingsState();
}

class _GiveRatingsState extends State<GiveRatings> {
  var ratings = 3.0;
  var ratingsText = "Good";

  TextEditingController feedbackCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          // Heading
          Center(
              child: Text(
            'Give Ratings',
            style: mainHeadingText(),
          )),

          Dialog(
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
                  Center(
                    child: Text(
                      "Rate your Experience",
                      style: whiteColorText(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Divider(
                    height: 3,
                    thickness: 3,
                    color: iconColor,
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // Ratings
                  Center(
                    child: RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      itemCount: 5,
                      allowHalfRating: false,
                      direction: Axis.horizontal,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 48,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          ratings = rating;
                        });
                        if (rating == 1) {
                          setState(() {
                            ratingsText = "Very Bad";
                          });
                        }
                        if (rating == 2) {
                          setState(() {
                            ratingsText = "Bad";
                          });
                        }
                        if (rating == 3) {
                          setState(() {
                            ratingsText = "Good";
                          });
                        }
                        if (rating == 4) {
                          setState(() {
                            ratingsText = "Very Good";
                          });
                        }
                        if (rating == 5) {
                          setState(() {
                            ratingsText = "Excellent";
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  Center(
                    child: Text(
                      ratingsText,
                      style: whiteColorText(),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),
                  const Divider(
                    height: 3,
                    thickness: 3,
                    color: iconColor,
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: feedbackCtrl,
                        decoration: textFieldsDec().copyWith(hintText: "Please Provide Your Feed back"),
                        keyboardType: TextInputType.text,
                        style: whiteColorText(),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),
                  const Divider(
                    height: 3,
                    thickness: 3,
                    color: iconColor,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: ElevatedButton(
                        style: actionBtnWithGreenColor(),
                        onPressed: () {
                          //  Give Ratings to User
                          giveRatings();
                        },
                        child:
                            Text("Give Ratings", style: whiteColorButtonText()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  giveRatings() async {
    await db
        .ref()
        .child("repairRequest")
        .child(widget.requestId)
        .child("status")
        .set("Finished");

    final data = await db
        .ref()
        .child("repairRequest")
        .child(widget.requestId)
        .once();

    if (data.snapshot.value != null) {
      final mechanicId = (data.snapshot.value as Map)["mechanic"]["mechanicId"].toString();
      await db
          .ref()
          .child("users")
          .child(mechanicId)
          .child("mechanicInfo")
          .child("jobStatus")
          .set("idle");
    }

    Map feedbackMap = {
      "userName": currentUserData!.name,
      "ratings": ratings,
      "comment": feedbackCtrl.text.trim().toString(),
      "dt": DateTime.now().toString(),
    };

    await db
        .ref()
        .child("users")
        .child(widget.userId)
        .child("feedback")
        .child(currentUserData!.id!)
        .set(feedbackMap);
    // DatabaseReference feedback = db
    //     .ref()
    //     .child("users")
    //     .child(widget.userId)
    //     .child("feedback")
    //     .push();
    //
    // await feedback.set(feedbackMap);

    DatabaseReference ref = db.ref().child("users").child(widget.userId);
    final dataSnapshot = await ref.child("noOfRatings").once();

    if (dataSnapshot.snapshot.value == 0) {
      ref.child("ratings").set(ratings);
      ref.child("noOfRatings").set(1);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
      );
    } else {
      var noOfRatings = double.parse(dataSnapshot.snapshot.value.toString());
      var totalNoOfRatings = noOfRatings + 1;
      final ratingsSnapshot = await ref.child("ratings").once();
      var prevRatings = double.parse(ratingsSnapshot.snapshot.value.toString());
      var totalPrevRatings = prevRatings * noOfRatings;
      var newRatings = (totalPrevRatings + ratings) / totalNoOfRatings;
      ref.child("ratings").set(newRatings.toStringAsFixed(1));
      ref.child("noOfRatings").set(totalNoOfRatings);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
      );
    }
  }

}

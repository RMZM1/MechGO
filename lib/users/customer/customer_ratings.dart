import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';
import 'package:mechaniconthego/widgets/rating_tile.dart';

class CustomerRatings extends StatefulWidget {
  const CustomerRatings({Key? key}) : super(key: key);

  @override
  State<CustomerRatings> createState() => _CustomerRatingsState();
}

class _CustomerRatingsState extends State<CustomerRatings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var ratingsNumber = double.parse(currentUserData!.ratings.toString()).round();
  var titleStarsRating = "";
  @override
  void initState() {
    super.initState();
    setupRatingsTitle();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: UserNavigationDrawer(
        user: currentUserData,
      ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          //  Custom Drawer Hamburger button and Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //  Custom Drawer Hamburger button
              Container(
                margin: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    //  It will open Drawer
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: const CircleAvatar(
                    backgroundColor: themeColor,
                    child: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              //Heading
              Container(
                margin: const EdgeInsets.all(20),
                child: Center(
                    child: Text(
                      'Your Ratings',
                      style: mainHeadingText(),
                    )),
              ),
            ],
          ),

          //OverAll Ratings
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: RatingBarIndicator(
                  rating: double.parse(currentUserData!.ratings.toString()),
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  "${currentUserData!.noOfRatings}",
                  style: greyColorText(),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 12.0,
          ),
          Text(
            titleStarsRating,
            style: greyColorButtonText(),),
          const SizedBox(
            height: 12.0,
          ),
          const Divider(
            thickness: 1,
            height: 1,
            color: Colors.black,
          ),
          //Customers Feedbacks
          const SizedBox(
            height: 18.0,
          ),
          (allRatings.isNotEmpty)
              ? Expanded(
                  child: ListView.separated(
                    itemCount: allRatings.length,
                    physics: const ClampingScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      return RatingTile(ratingsModel: allRatings[index]);
                    },
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    child: Text(
                      "You have No Reviews",
                      style: greyColorButtonText(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  setupRatingsTitle() {
    if (ratingsNumber == 1) {
      setState(() {
        titleStarsRating = "Very Bad";
      });
    }
    if (ratingsNumber == 2) {
      setState(() {
        titleStarsRating = "Bad";
      });
    }
    if (ratingsNumber == 3) {
      setState(() {
        titleStarsRating = "Good";
      });
    }
    if (ratingsNumber == 4) {
      setState(() {
        titleStarsRating = "Very Good";
      });
    }
    if (ratingsNumber == 5) {
      setState(() {
        titleStarsRating = "Excellent";
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/global/keys.dart';
import 'package:mechaniconthego/model/near_by_places_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/hotel_tile.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';

class FindNearByHotels extends StatefulWidget {
  const FindNearByHotels({Key? key}) : super(key: key);

  @override
  State<FindNearByHotels> createState() => _FindNearByHotelsState();
}

class _FindNearByHotelsState extends State<FindNearByHotels> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<NearByPlaces> nearByHotels = [];
  bool _isLoading = false;

  @override
  void initState() {
    searchNearByHotel();
    super.initState();
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
        body: Column(children: [
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
                  'Nearby Hotels',
                  style: mainHeadingText(),
                )),
              ),
            ],
          ),

          //Results
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: ProgressDialog(message: "Loading! Please Wait"),
                  ),
                )
              : (nearByHotels.isNotEmpty)
                  ? Expanded(
                      child: ListView.separated(
                        itemCount: nearByHotels.length,
                        physics: const ClampingScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 1,
                          );
                        },
                        itemBuilder: (context, index) {
                          return HotelTile(hotel: nearByHotels[index]);
                        },
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 300,
                        child: Text(
                          "We Are very Sorry for the Inconvenience. We could not find any nearby hotels please try again later",
                          style: greyColorButtonText(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
        ]));
  }

  //Get NearBy Places
  void searchNearByHotel() async {
    setState(() {
      _isLoading = true;
    });
    double radius = 5000.00; //in Meters
    String keyword = 'hotel';
    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${userCurrentPosition!.latitude.toString()},${userCurrentPosition!.longitude.toString()}&radius=$radius&keyword=$keyword&key=$mobileMapKey";
    var requestResponse = await AssistantMethods.receiveRequest(url);
    if (requestResponse == "An Error Occurred") {
      setState(() {
        _isLoading= false;
      });
      Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (requestResponse["status"] == "OK") {
      var resp = requestResponse["results"]; //Nearby Hotels
      var results = (resp as List)
          .map((jsonData) => NearByPlaces.fromJson(jsonData))
          .toList();
      setState(() {
        nearByHotels = results;
        _isLoading = false;
      });
    }
  }
}

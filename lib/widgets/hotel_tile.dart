import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/infoHandler/app_info.dart';
import 'package:mechaniconthego/model/directions_details.dart';
import 'package:mechaniconthego/model/near_by_places_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/customer/customer_main.dart';
import 'package:mechaniconthego/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

class HotelTile extends StatefulWidget {
  final NearByPlaces hotel;

  const HotelTile({Key? key, required this.hotel}) : super(key: key);
  @override
  State<HotelTile> createState() => _HotelTileState();
}

class _HotelTileState extends State<HotelTile> {
  int? endName; //For Substring
  int? endAddress; //For Substring
  DirectionDetails? customerToHotelDirections;

  @override
  void initState() {
    endName = widget.hotel.name!.length < 20 ? widget.hotel.name!.length : 20;

    endAddress =
        widget.hotel.vicinity!.length < 25 ? widget.hotel.vicinity!.length : 25;

    getCustomerToHotelDetails();
    super.initState();
    Timer(const Duration(seconds: 2), () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          bool res = await getNextLocation(
              widget.hotel.placeId!,
              widget.hotel.name!,
              widget.hotel.latitude!,
              widget.hotel.longitude!,
              context);
          if (res == true) {
            await getRoutes();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CustomerMain()));
          }
        },
        style: actionBtnWithThemeColor(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Name
                  Text(
                    widget.hotel.name!.length < 20
                        ? widget.hotel.name!
                        : "${widget.hotel.name!.toString().substring(0, endName)}...",
                    style: whiteColorButtonText(),
                  ),
                  //Address
                  SizedBox(
                    width: 200,
                    child: Text(
                      widget.hotel.vicinity!.length < 25
                          ? widget.hotel.vicinity!
                          : "${widget.hotel.vicinity!.toString().substring(0, endAddress)}...",
                      style: whiteColorText(),
                    ),
                  ),
                  //Ratings
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: double.parse(widget.hotel.rating!.toString()),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${widget.hotel.userRatingsTotal!}",
                          style: whiteColorText(),
                        ),
                      ),
                    ],
                  ),
                  //Distance Duration
                  Text(
                    customerToHotelDirections != null
                        ? "${customerToHotelDirections!.distanceText}, ~${customerToHotelDirections!.durationText}"
                        : "Cal...",
                    style: whiteColorText(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Directions Text
                  const Text(
                    "Click To Get Directions",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.hotel_rounded,
                size: 64,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getRoutes() async {
    showDialog(
        context: context,
        barrierDismissible: false, //it should not disappear on user click
        builder: (BuildContext context) {
          return const ProgressDialog(message: "Loading! Please Wait ");
        });

    //Get CurrentPosition latitude and longitude
    var oLat = Provider.of<AppInformation>(context, listen: false)
        .userCurrentLocation!
        .locationLatitude!;
    var oLng = Provider.of<AppInformation>(context, listen: false)
        .userCurrentLocation!
        .locationLongitude!;
    //Origin LatLng
    LatLng origin = LatLng(oLat, oLng);
    //Get Destination latitude and longitude
    var dLat = Provider.of<AppInformation>(context, listen: false)
        .userNextLocation!
        .locationLatitude!;
    var dLng = Provider.of<AppInformation>(context, listen: false)
        .userNextLocation!
        .locationLongitude!;
    //Destination Latitude and longitude
    LatLng destination = LatLng(dLat, dLng);

    DirectionDetails directionDetails =
        await AssistantMethods.getDirectionsFromOriginToDestination(
            origin, destination);
    directionDetailsInfo = directionDetails;
    Navigator.pop(context);
  }

  getCustomerToHotelDetails() async {
    LatLng hotelLocationLatLng =
        LatLng(widget.hotel.latitude, widget.hotel.longitude);
    LatLng userLocationLatLng =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    DirectionDetails customerToHotelDirectionsDetails =
        await AssistantMethods.getDirectionsFromOriginToDestination(
            userLocationLatLng, hotelLocationLatLng);

    customerToHotelDirections = customerToHotelDirectionsDetails;
  }
}

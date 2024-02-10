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

class GasStationTile extends StatefulWidget {
  final NearByPlaces gasStation;
  const GasStationTile({Key? key, required this.gasStation}) : super(key: key);
  @override
  State<GasStationTile> createState() => _GasStationTileState();
}

class _GasStationTileState extends State<GasStationTile> {
  int? endName; //For Substring
  int? endAddress; //For Substring

  DirectionDetails? customerToStationDirections;

  @override
  void initState() {
    endName = widget.gasStation.name!.length < 20
        ? widget.gasStation.name!.length
        : 20;

    endAddress = widget.gasStation.vicinity!.length < 25
        ? widget.gasStation.vicinity!.length
        : 25;

    getCustomerToStationDetails();
    super.initState();
    Timer(const Duration(seconds: 2), ()=>setState(() {}));
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          bool res = await getNextLocation(
              widget.gasStation.placeId!,
              widget.gasStation.name!,
              widget.gasStation.latitude!,
              widget.gasStation.longitude!,
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
                    widget.gasStation.name!.length < 20
                        ? widget.gasStation.name!
                        : "${widget.gasStation.name!.toString().substring(0, endName)}...",
                    style: whiteColorButtonText(),
                  ),
                  //Address
                  SizedBox(
                    width: 200,
                    child: Text(
                      widget.gasStation.vicinity!.length < 25
                          ? widget.gasStation.vicinity!
                          : "${widget.gasStation.vicinity!.toString().substring(0, endAddress)}...",
                      style: whiteColorText(),
                    ),
                  ),
                  //Ratings
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating:
                            double.parse(widget.gasStation.rating!.toString()),
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
                          "${widget.gasStation.userRatingsTotal!}",
                          style: whiteColorText(),
                        ),
                      ),
                    ],
                  ),
                  //Distance Duration
                  Text(
                    customerToStationDirections != null
                        ? "${customerToStationDirections!.distanceText}, ~${customerToStationDirections!.durationText}"
                        :"Cal...",
                    style: whiteColorText(),),
                  const SizedBox(height: 10,),
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
                Icons.local_gas_station_rounded,
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

  getCustomerToStationDetails() async{

    LatLng hotelLocationLatLng = LatLng(
        widget.gasStation.latitude, widget.gasStation.longitude
    );
    LatLng userLocationLatLng =
    LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    DirectionDetails customerToGasStationDirectionsDetails =
    await AssistantMethods.getDirectionsFromOriginToDestination(
        userLocationLatLng, hotelLocationLatLng);

    customerToStationDirections = customerToGasStationDirectionsDetails;
  }
}

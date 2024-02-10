import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mechaniconthego/assistants/assistants_methods.dart';
import 'package:mechaniconthego/assistants/geo_fire_assistant.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/model/directions_details.dart';
import 'package:mechaniconthego/model/user_model.dart';
import 'package:mechaniconthego/styles/styles.dart';

class NearByOnlineMechanicTile extends StatefulWidget {
  final UserModel mechanic;
  final String problem;

  const NearByOnlineMechanicTile(
      {Key? key, required this.mechanic, required this.problem})
      : super(key: key);
  @override
  State<NearByOnlineMechanicTile> createState() =>
      _NearByOnlineMechanicTileState();
}

class _NearByOnlineMechanicTileState extends State<NearByOnlineMechanicTile> {
  DirectionDetails? mechanicToCustomerDirectionDetails;
  dynamic fareAmount;
  dynamic problemPrice;
  dynamic totalPrice;
  @override
  void initState() {
    getMechanicToCustomerDetails();
    super.initState();
    Timer(const Duration(seconds: 2), () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            chosenMechanicId = widget.mechanic.id!;
            fareAmountForChosenMechanic = fareAmount;
          });
          Navigator.pop(context, "mechanicChosen");
        },
        style: actionBtnWithThemeColor(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Mechanic Info
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.mechanic.profilePic == null
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.person,
                            color: iconColor,
                            size: 54,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            elevation: 8,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: InkWell(
                              onTap: () {},
                              child: Ink.image(
                                image: NetworkImage(
                                    "${widget.mechanic.profilePic}"),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                  //Mechanic info
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Name
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            widget.mechanic.name!,
                            style: whiteColorButtonText(),
                          ),
                        ),
                        //Email
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            widget.mechanic.email!,
                            style: whiteColorText(),
                          ),
                        ),
                        //Phone
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            widget.mechanic.phone!,
                            style: whiteColorText(),
                          ),
                        ),
                        //Ratings
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: double.parse(
                                  widget.mechanic.ratings!.toString()),
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
                                "${widget.mechanic.noOfRatings!}",
                                style: whiteColorText(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //  Price and time
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Distance and Duration
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Distance
                        Text(
                          mechanicToCustomerDirectionDetails != null
                              ? "Distance: ${mechanicToCustomerDirectionDetails!.distanceText}"
                              : "Distance: ...",
                          style: whiteColorText(),
                        ),
                        //Duration
                        Text(
                          mechanicToCustomerDirectionDetails != null
                              ? "Arrival Time: ~${mechanicToCustomerDirectionDetails!.durationText}"
                              : "Arrival Time: ...",
                          style: whiteColorText(),
                        ),
                      ],
                    ),
                  ),
                  //Charges
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Charges
                        Text(
                          fareAmount != null
                              ? "Fare: $fareAmount Rs"
                              : "Fare: ...",
                          style: whiteColorText(),
                        ),
                        Text(
                          problemPrice != null
                              ? "Charges: $problemPrice"
                              : "Charges: ...",
                          style: whiteColorText(),
                        ),
                      ],
                    ),
                  ),
                  //Total
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      totalPrice != null ? "Total: $totalPrice" : "Total: ...",
                      style: whiteColorText(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getMechanicToCustomerDetails() async {
    var index = GeoFireAssistant.nearByOnlineMechanicsList
        .indexWhere((element) => element.mechanicsId == widget.mechanic.id);

    var mechanicLat =
        GeoFireAssistant.nearByOnlineMechanicsList[index].locationLatitude;
    var mechanicLng =
        GeoFireAssistant.nearByOnlineMechanicsList[index].locationLongitude;
    LatLng mechanicLocationLatLng = LatLng(mechanicLat!, mechanicLng!);
    LatLng userLocationLatLng =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    DirectionDetails mechanicToCustomerDirectionsDetails =
        await AssistantMethods.getDirectionsFromOriginToDestination(
            mechanicLocationLatLng, userLocationLatLng);

    mechanicToCustomerDirectionDetails = mechanicToCustomerDirectionsDetails;
    fareAmount = await AssistantMethods.getFareAmount(
        mechanicToCustomerDirectionsDetails);
    getProblemPrice();
  }

  getProblemPrice() {
    switch (widget.problem) {
      case "Battery":
        problemPrice =
            "${widget.mechanic.priceList["Battery"]["minPrice"]}Rs - ${widget.mechanic.priceList["Battery"]["maxPrice"]}Rs";
        var min = int.parse(widget.mechanic.priceList["Battery"]["minPrice"]) +
            int.parse(fareAmount.toString());
        var max = int.parse(widget.mechanic.priceList["Battery"]["maxPrice"]) +
            int.parse(fareAmount.toString());
        totalPrice = "$min Rs - $max Rs";
        break;
      case "Brakes":
        problemPrice =
            "${widget.mechanic.priceList["Brakes"]["minPrice"]}Rs - ${widget.mechanic.priceList["Brakes"]["maxPrice"]}Rs";
        var min = int.parse(widget.mechanic.priceList["Brakes"]["minPrice"]) +
            int.parse(fareAmount.toString());
        var max = int.parse(widget.mechanic.priceList["Brakes"]["maxPrice"]) +
            int.parse(fareAmount.toString());
        totalPrice = "$min Rs - $max Rs";
        break;
      case "Oil Change":
        problemPrice = "${widget.mechanic.priceList["OilChange"]["price"]}Rs";
        var price = int.parse(widget.mechanic.priceList["OilChange"]["price"]) +
            int.parse(fareAmount.toString());
        totalPrice = "$price Rs";
        break;
      case "Puncture":
        problemPrice =
            "${widget.mechanic.priceList["Puncture"]["price"]}Rs /Puncture";
        // var price = int.parse(widget.mechanic.priceList["Puncture"]["price"]) + int.parse(fareAmount.toString());
        totalPrice =
            "${widget.mechanic.priceList["Puncture"]["price"]}Rs x Number of Punctures + $fareAmount Rs";
        break;
      case "Head Lights":
        problemPrice =
            "${widget.mechanic.priceList["HeadLights"]["minPrice"]}Rs - ${widget.mechanic.priceList["HeadLights"]["maxPrice"]}Rs";
        var min =
            int.parse(widget.mechanic.priceList["HeadLights"]["minPrice"]) +
                int.parse(fareAmount.toString());
        var max =
            int.parse(widget.mechanic.priceList["HeadLights"]["maxPrice"]) +
                int.parse(fareAmount.toString());
        totalPrice = "$min Rs - $max Rs";
        break;
      case "Back Lights":
        problemPrice =
            "${widget.mechanic.priceList["BackLights"]["minPrice"]}Rs - ${widget.mechanic.priceList["TailLights"]["maxPrice"]}Rs";
        var min =
            int.parse(widget.mechanic.priceList["BackLights"]["minPrice"]) +
                int.parse(fareAmount.toString());
        var max =
            int.parse(widget.mechanic.priceList["BackLights"]["maxPrice"]) +
                int.parse(fareAmount.toString());
        totalPrice = "$min Rs - $max Rs";
        break;
      case "Side Mirrors":
        problemPrice =
            "${widget.mechanic.priceList["SideMirrors"]["minPrice"]}Rs - ${widget.mechanic.priceList["SideMirrors"]["maxPrice"]}Rs";
        var min =
            int.parse(widget.mechanic.priceList["SideMirrors"]["minPrice"]) +
                int.parse(fareAmount.toString());
        var max =
            int.parse(widget.mechanic.priceList["SideMirrors"]["maxPrice"]) +
                int.parse(fareAmount.toString());
        totalPrice = "$min Rs - $max Rs";
        break;
      case "Suspension":
        problemPrice =
            "${widget.mechanic.priceList["Suspension"]["minPrice"]}Rs - ${widget.mechanic.priceList["Suspension"]["maxPrice"]}Rs";
        var min =
            int.parse(widget.mechanic.priceList["Suspension"]["minPrice"]) +
                int.parse(fareAmount.toString());
        var max =
            int.parse(widget.mechanic.priceList["Suspension"]["maxPrice"]) +
                int.parse(fareAmount.toString());
        totalPrice = "$min Rs - $max Rs";
        break;
      case "Tyre":
        problemPrice =
            "${widget.mechanic.priceList["Tyre"]["minPrice"]}Rs - ${widget.mechanic.priceList["Tyre"]["maxPrice"]}Rs";
        var min = int.parse(widget.mechanic.priceList["Tyre"]["minPrice"]) +
            int.parse(fareAmount.toString());
        var max = int.parse(widget.mechanic.priceList["Tyre"]["maxPrice"]) +
            int.parse(fareAmount.toString());
        totalPrice = "$min Rs - $max Rs";
        break;
      default:
        problemPrice = "Depends on Problem";
        totalPrice = "Depends on Problem";
        break;
    }
  }
}

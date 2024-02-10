import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/customer/customer_main.dart';
import 'package:mechaniconthego/widgets/near_by_online_mechanic_tile.dart';

class NearByOnlineMechanicsScreen extends StatefulWidget {
  final String selectedProblem;
  final DatabaseReference referenceRequest;

  const NearByOnlineMechanicsScreen(
      {Key? key, required this.selectedProblem, required this.referenceRequest})
      : super(key: key);
  @override
  State<NearByOnlineMechanicsScreen> createState() =>
      _NearByOnlineMechanicsScreenState();
}

class _NearByOnlineMechanicsScreenState
    extends State<NearByOnlineMechanicsScreen> {
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
          //  Custom Drawer Hamburger button and Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //  Custom Drawer Hamburger button
              Container(
                margin: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    //Delete remove Request
                    widget.referenceRequest.remove();
                    //  Move Back to home Screen
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CustomerMain()));
                  },
                  child: const CircleAvatar(
                    backgroundColor: themeColor,
                    child: Icon(
                      Icons.close,
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
                  'Available Mechanics',
                  style: mainHeadingText(),
                )),
              ),
            ],
          ),

          //Results
          (mechanicList.isNotEmpty)
              ? Expanded(
                  child: ListView.separated(
                    itemCount: mechanicList.length,
                    physics: const ClampingScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      return NearByOnlineMechanicTile(
                        mechanic: mechanicList[index],
                        problem: widget.selectedProblem,
                      );
                    },
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    child: Text(
                      "We Are very Sorry for the Inconvenience Currently the available mechanics in the area are Busy. please try again later",
                      style: greyColorButtonText(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

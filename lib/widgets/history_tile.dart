import 'package:flutter/material.dart';
import 'package:mechaniconthego/model/repair_request_model.dart';
import 'package:mechaniconthego/styles/styles.dart';

class HistoryTile extends StatefulWidget {

  final RepairRequestModel requestModel;

  const HistoryTile({Key? key, required this.requestModel}) : super(key: key);

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      color: themeColor,
      child: Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.location_on_sharp, color: iconColor, size: 24,),
                SizedBox(
                  width: 250,
                  child: Text(
                    "${widget.requestModel.customerLocationName}",
                    style: whiteColorText(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 3,
            color: Colors.white,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Problem: ${widget.requestModel.problem}",
                  style: whiteColorText(),
                ),
                Text(
                  "Total Charges: ${widget.requestModel.totalCharges} Rs",
                  style: whiteColorText(),
                ),
              ],
            ),
          ),

          const Divider(
            height: 3,
            color: Colors.white,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Payment: ${widget.requestModel.paymentMethod}",
                  style: whiteColorText(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date: ${formatDate(widget.requestModel.time.toString())}",
                      style: whiteColorText(),
                    ),
                    Text(
                      "Time: ${formatTime(widget.requestModel.time.toString())}",
                      style: whiteColorText(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }


  String formatDate(String dateTime){
    DateTime dt = DateTime.parse(dateTime);
    return "${dt.day}-${dt.month}-${dt.year}";
  }
  String formatTime(String dateTime){
    DateTime dt = DateTime.parse(dateTime);
    return "${dt.hour}:${dt.minute}:${dt.second}";
  }

}

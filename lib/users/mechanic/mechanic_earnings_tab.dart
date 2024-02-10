import 'package:flutter/material.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/history_tile.dart';

class MechanicEarnings extends StatefulWidget {
  const MechanicEarnings({Key? key}) : super(key: key);

  @override
  State<MechanicEarnings> createState() => _MechanicEarningsState();
}

class _MechanicEarningsState extends State<MechanicEarnings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Center(
              child: Text(
            "Earnings",
            style: mainHeadingText(),
          )),
          const SizedBox(
            height: 5,
          ),
          //Total Earnings
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your Earnings: ",
                  style: greyColorText(),
                ),
                Text(
                  "PKR ${currentUserData!.totalEarnings}",
                  style: greyColorText(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Requests Completed: ",
                  style: greyColorText(),
                ),
                Text(
                  "${requestHistory.length}",
                  style: greyColorText(),
                ),
              ],
            ),
          ),
          const Divider(
            height: 5,
            thickness: 2,
            color: Colors.grey,
          ),
          //  History
          const SizedBox(
            height: 5,
          ),
          Center(
              child: Text(
            "History",
            style: mainHeadingText(),
          )),
          const SizedBox(
            height: 5,
          ),

          (requestHistory.isNotEmpty)
              ? Expanded(
                  child: ListView.separated(
                    itemCount: requestHistory.length,
                    physics: const ClampingScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      return HistoryTile(
                        requestModel: requestHistory[index],
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
                      "There is no Recent History",
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

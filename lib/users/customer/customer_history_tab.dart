import 'package:flutter/material.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/widgets/history_tile.dart';
import 'package:mechaniconthego/widgets/navigation_drawer.dart';

class CustomerHistory extends StatefulWidget {
  const CustomerHistory({Key? key}) : super(key: key);

  @override
  State<CustomerHistory> createState() => _CustomerHistoryState();
}

class _CustomerHistoryState extends State<CustomerHistory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
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
                  'History',
                  style: mainHeadingText(),
                )),
              ),
            ],
          ),

          // History of Customer
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

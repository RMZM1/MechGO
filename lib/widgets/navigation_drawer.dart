import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mechaniconthego/splash_screen.dart';
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/model/user_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/customer/customer_ratings.dart';
import 'package:mechaniconthego/users/customer/find_near_by_gas_station.dart';
import 'package:mechaniconthego/users/customer/find_near_by_hotel.dart';
import 'package:mechaniconthego/users/update/become_mechanic.dart';
import 'package:mechaniconthego/users/customer/customer_account_tab.dart';
import 'package:mechaniconthego/users/customer/customer_history_tab.dart';
import 'package:mechaniconthego/users/customer/customer_main.dart';

class UserNavigationDrawer extends StatefulWidget {
  final UserModel? user;
  const UserNavigationDrawer({super.key, this.user});

  @override
  State<UserNavigationDrawer> createState() => _UserNavigationDrawerState();
}

class _UserNavigationDrawerState extends State<UserNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: themeColor,
      child: ListView(
        children: [
          //  Drawer Header
          Container(
            height: 180,
            color: themeColor,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white54),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //DP

                      currentUserData!.profilePic == null
                          ? const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.person,
                                color: iconColor,
                                size: 70,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Material(
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: InkWell(
                                  onTap: () {},
                                  child: Ink.image(
                                    image: NetworkImage(
                                        "${currentUserData!.profilePic}"),
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),


                      const SizedBox(
                        height: 10,
                      ),
                      RatingBarIndicator(
                        rating: double.parse(widget.user!.ratings.toString()),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 15.0,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text("${widget.user!.name}",
                            style: whiteColorButtonText()),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 150,
                        child: Text("${widget.user!.email}",
                            textAlign: TextAlign.left, style: whiteColorText()),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("${widget.user!.phone}",
                          textAlign: TextAlign.right, style: whiteColorText()),
                      const SizedBox(
                        height: 10,
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
          // Divider
          const Divider(
            height: 1,
            thickness: 12,
            color: Colors.black,
          ),

          //  Drawer Body
          //Home
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerMain(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                Icons.home,
                color: iconColor,
              ),
              title: Text("Home", style: whiteColorText()),
            ),
          ),
          //Profile
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerAccount(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                Icons.person,
                color: iconColor,
              ),
              title: Text("Profile", style: whiteColorText()),
            ),
          ),
          //History
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerHistory(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                Icons.history,
                color: iconColor,
              ),
              title: Text("History", style: whiteColorText()),
            ),
          ),

          //Ratings
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerRatings(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                Icons.star,
                color: iconColor,
              ),
              title: Text("My Ratings", style: whiteColorText()),
            ),
          ),

          //Become A mechanic
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterMechanic(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                // Icons.add,
                MdiIcons.wrench,
                color: iconColor,
              ),
              title: Text("Become a Mechanic", style: whiteColorText()),
            ),
          ),

          //Find Hotel
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindNearByHotels(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                Icons.hotel_rounded,
                color: iconColor,
              ),
              title: Text("Find Hotel", style: whiteColorText()),
            ),
          ),

          //Find GasStations
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindNearByGasStation(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                Icons.local_gas_station_rounded,
                color: iconColor,
              ),
              title: Text("Find Petrol Pump", style: whiteColorText()),
            ),
          ),

          //Sign out
          GestureDetector(
            onTap: () {
              fAuth.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  ));
            },
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: iconColor,
              ),
              title: Text("Logout", style: whiteColorText()),
            ),
          ),
        ],
      ),
    );
  }
}

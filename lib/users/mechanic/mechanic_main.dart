import 'package:flutter/material.dart';
import 'package:mechaniconthego/styles/styles.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_account_tab.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_earnings_tab.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_home_tab.dart';
import 'package:mechaniconthego/users/mechanic/mechanic_ratings_tab.dart';

class MechanicMain extends StatefulWidget {
  const MechanicMain({super.key});

  @override
  State<MechanicMain> createState() => _MechanicMainState();
}

class _MechanicMainState extends State<MechanicMain>
    with SingleTickerProviderStateMixin {
  TabController? tabController; //this is controller used for tabBarView
  int selectedIndex =
      0; //This is index of the current i.e Home, Earnings, History etc

  //When tapping on home page it will assign its index
  // to tab controller and navigate to home page (Like Intents)
  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    //4 tabs Home, Profile(Account), Earnings(History), Ratings
    tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Mechanic On The Go",
          style: pageHeadingText(),
        )),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          MechanicHome(),
          MechanicEarnings(),
          MechanicRatings(),
          MechanicAccount(),
        ],
      ),
      //  Here is Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: themeColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: navigationLabels(),
        unselectedLabelStyle: navigationLabels(),
        iconSize: 32,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Ratings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}

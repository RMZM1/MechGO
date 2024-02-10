import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  dynamic ratings;
  int? noOfRatings;
  bool? isMechanic;
  dynamic mechanicInfo;
  dynamic priceList;
  dynamic totalEarnings;
  String? profilePic;
  bool? isBlocked;
  String? stripeAccountId;
  bool? stripeOnBoardingComplete;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.ratings,
    this.noOfRatings,
    this.isMechanic,
    this.mechanicInfo,
    this.priceList,
    this.totalEarnings,
    this.profilePic,
    this.isBlocked,
    this.stripeAccountId,
    this.stripeOnBoardingComplete,
  });

  //To get and store data from database
  UserModel.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    name = (snapshot.value as dynamic)['name'];
    email = (snapshot.value as dynamic)['email'];
    phone = (snapshot.value as dynamic)['phone'];
    ratings = (snapshot.value as dynamic)['ratings'];
    noOfRatings = (snapshot.value as dynamic)['noOfRatings'];
    isMechanic = (snapshot.value as dynamic)['isMechanic'];
    mechanicInfo = (snapshot.value as dynamic)['mechanicInfo'];
    priceList = (snapshot.value as dynamic)['priceList'];
    totalEarnings = (snapshot.value as dynamic)['totalEarnings'];
    profilePic = (snapshot.value as dynamic)['profilePic'];
    isBlocked = (snapshot.value as dynamic)['isBlocked'];
    stripeAccountId = (snapshot.value as dynamic)['stripeAccountId'];
    stripeOnBoardingComplete = (snapshot.value as dynamic)['stripeOnBoardingComplete'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'ratings': ratings,
      'noOfRatings': noOfRatings,
      'isMechanic': isMechanic,
      'mechanicInfo': mechanicInfo,
      'priceList': priceList,
      'totalEarnings': totalEarnings,
      'profilePic': profilePic,
      'isBlocked': isBlocked,
      'stripeAccountId': stripeAccountId,
      'stripeOnBoardingComplete': stripeOnBoardingComplete,
    };
  }
}

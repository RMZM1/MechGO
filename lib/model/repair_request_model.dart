import 'package:firebase_database/firebase_database.dart';

class RepairRequestModel {
  String? requestId;
  double? customerLocLat;
  double? customerLocLng;
  String? customerLocationName;
  String? problem;
  String? vehicleInfo;
  String? customerId;
  String? customerName;
  String? customerEmail;
  String? customerPhone;
  dynamic customerRatings;
  int? customerNoOfRatings;
  String? mechanicId;
  String? mechanicName;
  String? mechanicPhone;
  String? mechanicEmail;
  dynamic mechanicRatings;
  int? mechanicNoOfRatings;
  dynamic fareAmount;
  dynamic charges;
  dynamic totalCharges;
  String? status;
  String? paymentMethod;
  String? time;
  dynamic customerBudget;


  RepairRequestModel({
    this.requestId,
    this.customerLocLat,
    this.customerLocLng,
    this.customerLocationName,
    this.problem,
    this.vehicleInfo,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerRatings,
    this.customerNoOfRatings,
    this.mechanicId,
    this.mechanicName,
    this.mechanicPhone,
    this.mechanicEmail,
    this.mechanicRatings,
    this.mechanicNoOfRatings,
    this.fareAmount,
    this.charges,
    this.totalCharges,
    this.status,
    this.paymentMethod,
    this.time,
    this.customerBudget,
  });

  RepairRequestModel.fromSnapshot(DataSnapshot snapshot){
    requestId = snapshot.key;
    customerLocLat = (snapshot.value as dynamic)["customerLocation"]["latitude"];
    customerLocLng = (snapshot.value as dynamic)["customerLocation"]["latitude"];
    customerLocationName = (snapshot.value as dynamic)["customerReadableAddress"];
    problem = (snapshot.value as dynamic)["problem"];
    vehicleInfo = (snapshot.value as dynamic)["vehicleInfo"];
    customerId = (snapshot.value as dynamic)["customer"]["id"];
    customerName = (snapshot.value as dynamic)["customer"]["name"];
    customerEmail = (snapshot.value as dynamic)["customer"]["email"];
    customerPhone = (snapshot.value as dynamic)["customer"]["phone"];
    customerRatings = (snapshot.value as dynamic)["customer"]["ratings"];
    customerNoOfRatings = (snapshot.value as dynamic)["customer"]["noOfRatings"];
    mechanicId = (snapshot.value as dynamic)["mechanic"]["mechanicId"];
    mechanicName = (snapshot.value as dynamic)["mechanic"]["mechanicName"];
    mechanicPhone = (snapshot.value as dynamic)["mechanic"]["mechanicPhone"];
    mechanicEmail = (snapshot.value as dynamic)["mechanic"]["mechanicEmail"];
    mechanicRatings = (snapshot.value as dynamic)["mechanic"]["mechanicRatings"];
    mechanicNoOfRatings = (snapshot.value as dynamic)["mechanic"]["mechanicNoOfRatings"];
    fareAmount = (snapshot.value as dynamic)["fareAmount"];
    charges = (snapshot.value as dynamic)["charges"];
    totalCharges = (snapshot.value as dynamic)["totalCharges"];
    status = (snapshot.value as dynamic)["status"];
    paymentMethod = (snapshot.value as dynamic)["paymentMethod"];
    time = (snapshot.value as dynamic)["time"];
    customerBudget = (snapshot.value as dynamic)["customerBudget"];
  }
}

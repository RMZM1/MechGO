import 'package:firebase_database/firebase_database.dart';

class Ratings{
  String? userName;
  dynamic ratings;
  String? comment;
  String? dt;

  Ratings({
    this.userName,
    this.ratings,
    this.comment,
    this.dt,
});

  Ratings.fromSnapshot(DataSnapshot snapshot){
    userName = (snapshot.value as dynamic)['userName'];
    ratings = (snapshot.value as dynamic)['ratings'];
    comment = (snapshot.value as dynamic)['comment'];
    dt = (snapshot.value as dynamic)['dt'];
  }

}
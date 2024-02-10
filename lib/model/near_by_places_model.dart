class NearByPlaces {
  dynamic latitude;
  dynamic longitude;
  String? name;
  String? placeId;
  dynamic rating;
  int? userRatingsTotal;
  String? vicinity;

  NearByPlaces.fromJson(Map<String, dynamic> jsonData) {
    latitude = jsonData["geometry"]["location"]["lat"];
    longitude = jsonData["geometry"]["location"]["lng"];
    name = jsonData["name"];
    placeId = jsonData["place_id"];
    rating = jsonData["rating"];
    userRatingsTotal = jsonData["user_ratings_total"];
    vicinity = jsonData["vicinity"];
  }
}

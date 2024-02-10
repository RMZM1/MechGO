import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mechaniconthego/model/rating_model.dart';
import 'package:mechaniconthego/styles/styles.dart';
class RatingTile extends StatefulWidget {
  final Ratings ratingsModel;
  const RatingTile({Key? key, required this.ratingsModel}) : super(key: key);

  @override
  State<RatingTile> createState() => _RatingTileState();
}

class _RatingTileState extends State<RatingTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      decoration: textButtonContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
            child: Row(
              children: [
                Text(
                  "${widget.ratingsModel.userName} /",
                  style: greyColorButtonText(),
                ),
                Text(
                  widget.ratingsModel.dt.toString().split(" ")[0],
                  style: greyColorText(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
            child: RatingBarIndicator(
              rating: double.parse(widget.ratingsModel.ratings.toString()),
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 10.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.ratingsModel.comment != null ? "${widget.ratingsModel.comment}":"",
              style: greyColorButtonText(),
            ),
          ),

        ],
      ),
    );
  }
}

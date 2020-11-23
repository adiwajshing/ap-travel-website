import 'package:flutter/material.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/views/hotel_details_page.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard(this.hotel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          HotelDetailsPage.id,
          arguments: hotel.id,
        );
      },
      child: Container(
        width: 250,
        height: 290,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Image.network(
                hotel.thumbnail,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hotel.neighbourhood,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Text(
                          hotel.city,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${hotel.price.currency} ${hotel.price.currentPrice}',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow[700]),
                            Text(
                              hotel.rating.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

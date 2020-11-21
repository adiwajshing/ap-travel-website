class Booking {
  BookingDetails bookingDetails;
  String bookingId;
  String hotelId;
  int price;
  String status;
  String timestamp;
  String title;

  Booking(
      {this.bookingDetails,
      this.bookingId,
      this.hotelId,
      this.price,
      this.status,
      this.timestamp,
      this.title});

  Booking.fromJson(dynamic json) {
    bookingDetails = json['bookingDetails'] != null
        ? BookingDetails.fromJson(
            json['bookingDetails'] as Map<String, dynamic>,
          )
        : null;
    bookingId = json['bookingId'] as String;
    hotelId = json['hotelId'] as String;
    price = json['price'] as int;
    status = json['status'] as String;
    timestamp = json['timestamp'] as String;
    title = json['title'] as String;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    if (bookingDetails != null) {
      data['bookingDetails'] = bookingDetails.toMap();
    }
    data['status'] = status;
    return data;
  }
}

class BookingDetails {
  String bookingName;
  String checkIn;
  String checkOut;
  int guests;
  Room room;

  BookingDetails(
      {this.bookingName, this.checkIn, this.checkOut, this.guests, this.room});

  BookingDetails.fromJson(Map<String,dynamic> json) {
    bookingName = json['bookingName'] as String;
    checkIn = json['check_In'] as String;
    checkOut = json['check_Out'] as String;
    guests = json['guests'] as int;
    room = json['room'] != null
        ? Room.fromJson(json['room'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['bookingName'] = bookingName;
    data['check_In'] = checkIn;
    data['check_Out'] = checkOut;
    data['guests'] = guests;
    if (room != null) {
      data['room'] = room.toJson();
    }
    return data;
  }
}

class Room {
  int roomType;

  Room({this.roomType});

  Room.fromJson(Map<String, dynamic> json) {
    roomType = json['roomType'] as int;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['roomType'] = roomType;
    return data;
  }
}

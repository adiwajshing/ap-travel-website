class HotelOverview {
  int id;
  int starRating;
  String title;

  HotelOverview({this.id, this.starRating, this.title});

  HotelOverview.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    starRating = json['starRating'] as int;
    title = json['title'] as String;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['starRating'] = starRating;
    data['title'] = title;
    return data;
  }
}

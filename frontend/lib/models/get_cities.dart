class GetHome {
  List<Data> cities;
  List<Data> tags;
  List<Data> stars;
  GetHome({this.cities,this.stars,this.tags});

  GetHome.fromJson(Map<String, dynamic> json) {
    if (json['cities'] != null) {
      cities = <Data>[];
      tags = <Data>[];
      stars = <Data>[];
      json['cities'].forEach((v) {
        cities.add(Data.fromJson(v as Map<String, dynamic>));
      });
      json['stars'].forEach((v) {
        stars.add(Data.fromJson(v as Map<String, dynamic>));
      });
      json['tags'].forEach((v) {
        tags.add(Data.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (cities != null) {
      data['cities'] = cities.map((v) => v.toJson()).toList();
    }
    if (stars != null) {
      data['stars'] = stars.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String displayName;
  String tag;
  String thumbnail;

  Data({this.displayName, this.tag, this.thumbnail});

  Data.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'] as String;
    tag = json['tag'] as String;
    thumbnail = json['thumbnail'] as String;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['displayName'] = displayName;
    data['tag'] = tag;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
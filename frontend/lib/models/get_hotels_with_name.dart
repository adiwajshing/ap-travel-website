class GetHotelsWithName {
  String city;
  String destinationId;
  int id;
  String neighbourhood;
  Price price;
  int rating;
  int starRating;
  String thumbnail;
  String title;

  GetHotelsWithName(
      {city,
      destinationId,
      id,
      neighbourhood,
      price,
      rating,
      starRating,
      thumbnail,
      title});

  GetHotelsWithName.fromJson(Map<String, dynamic> json) {
    city = json['city'] as String;
    destinationId = json['destinationId'] as String;
    id = json['id'] as int;
    neighbourhood = json['neighbourhood'] as String;
    price = json['price'] != null
        ? Price.fromJson(json['price'] as Map<String, dynamic>)
        : null;
    rating = json['rating'] as int;
    starRating = json['starRating'] as int;
    thumbnail = json['thumbnail'] as String;
    title = json['title'] as String;
  }

  Map<String, dynamic> toJson() {
    // ignore: omit_local_variable_types
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['destinationId'] = destinationId;
    data['id'] = id;
    data['neighbourhood'] = neighbourhood;
    if (price != null) {
      data['price'] = price.toJson();
    }
    data['rating'] = rating;
    data['starRating'] = starRating;
    data['thumbnail'] = thumbnail;
    data['title'] = title;
    return data;
  }
}

class Price {
  int beforePrice;
  String currency;
  int currentPrice;
  bool discounted;
  int savingsAmount;
  int savingsPercent;

  Price(
      {beforePrice,
      currency,
      currentPrice,
      discounted,
      savingsAmount,
      savingsPercent});

  Price.fromJson(Map<String, dynamic> json) {
    beforePrice = json['before_price'] as int;
    currency = json['currency'] as String;
    currentPrice = json['current_price'] as int;
    discounted = json['discounted'] as bool;
    savingsAmount = json['savings_amount'] as int;
    savingsPercent = json['savings_percent'] as int;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['before_price'] = beforePrice;
    data['currency'] = currency;
    data['current_price'] = currentPrice;
    data['discounted'] = discounted;
    data['savings_amount'] = savingsAmount;
    data['savings_percent'] = savingsPercent;
    return data;
  }
}

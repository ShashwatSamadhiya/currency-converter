import 'package:currency_converter/currency_converter/models/currency_rate_response.dart';

class LocalCacheModel {
  final CurrencyResponse response;
  final int timestamp;

  LocalCacheModel({required this.response, required this.timestamp});

  factory LocalCacheModel.fromJson(Map<String, dynamic> json) {
    return LocalCacheModel(
      response: CurrencyResponse.fromJson(json['response']),
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"response": response.toJson(), "timestamp": timestamp};
  }
}

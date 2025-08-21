import 'dart:convert';

import 'package:currency_converter/currency_converter/models/quotes.dart';

/// Represents the response from the currency exchange rate list API.
///
class CurrencyResponse {
  final bool success;
  final String terms;
  final String privacy;
  final int timestamp;
  final String source;
  final List<Quote> quotes;

  late Map<String, double> _exchangeRate;

  double getExchangeRate(String symbol) {
    return _exchangeRate[symbol]!;
  }

  CurrencyResponse({
    required this.success,
    required this.terms,
    required this.privacy,
    required this.timestamp,
    required this.source,
    required this.quotes,
  }) {
    _exchangeRate = {for (var q in quotes) q.symbol: q.rate};
  }

  factory CurrencyResponse.fromJson(Map<String, dynamic> json) {
    final rawQuotes = Map<String, dynamic>.from(json['quotes']);

    /// add USDUSD to the quotes as the api does not return it in quotes
    rawQuotes['USDUSD'] = 1;
    return CurrencyResponse(
      success: json['success'],
      terms: json['terms'],
      privacy: json['privacy'],
      timestamp: json['timestamp'],
      source: json['source'],
      quotes:
          rawQuotes.entries
              .map((entry) => Quote.fromJson(entry.key, entry.value))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "terms": terms,
      "privacy": privacy,
      "timestamp": timestamp,
      "source": source,
      "quotes": {for (var q in quotes) q.symbol: q.rate},
    };
  }

  static CurrencyResponse fromJsonString(String str) =>
      CurrencyResponse.fromJson(json.decode(str));
}

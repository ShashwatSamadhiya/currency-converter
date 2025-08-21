///
/// this class is data model for the quotes
/// it contains the currency symbol and its rate
///
/// e.g. "USDZMK": 9001.203654,
///
class Quote {
  final String symbol;
  final double rate;

  late double changedRateForCurrency;

  Quote({required this.symbol, required this.rate}) {
    changedRateForCurrency = rate;
  }

  factory Quote.fromJson(String key, dynamic value) {
    return Quote(symbol: key, rate: (value as num).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {symbol: rate};
  }

  String get targetCurrency => symbol.substring(3);
}

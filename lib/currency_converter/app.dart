import 'dart:convert';

import 'package:currency_converter/currency_converter/models/currency_rate_response.dart';
import 'package:currency_converter/currency_converter/models/local_cache.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class CurrencyConverterApi {
  late http.Client _httpClient;

  CurrencyConverterApi({http.Client? httpClient}) {
    _httpClient = httpClient ?? http.Client();
  }

  /// Base API path for the currency converter service.
  final String _baseApiPath = "https://api.currencylayer.com/";

  /// Cache key for storing the response.
  /// This is used to avoid unnecessary network calls.
  final String _prefResponseCacheKey = "currency_converter_response";

  /// Access API key for the currency converter service.
  /// this key should be kept secure and not exposed in public repositories.
  /// but for the sake of this example, it is hardcoded.
  final String _accessApiKey = "45bbe408f0acf2d5c4924dc29f91a6ba";

  final Lock _lock = Lock();

  /// Cached response to avoid multiple network calls.
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  LocalCacheModel? _cachedResponse;

  LocalCacheModel? useCacheNewerThan3oMinutes(LocalCacheModel cacheResponse) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Check if the cached response is newer than 30 minutes (1800 seconds or 30 minutes)
    if (now - cacheResponse.timestamp < 1800) return cacheResponse;
    return null;
  }

  Future<LocalCacheModel?> cachedResponseCheck() async {
    if (_cachedResponse != null) {
      return useCacheNewerThan3oMinutes(_cachedResponse!);
    }

    final cachedData = (await _getPrefs).getString(_prefResponseCacheKey);
    if (cachedData == null) return null;

    final cache = LocalCacheModel.fromJson(json.decode(cachedData));

    return _cachedResponse = useCacheNewerThan3oMinutes(cache);
  }

  Future<CurrencyResponse> fetchExchangeRates() async {
    // Use the lock to ensure that only one request is made at a time
    return _lock.synchronized(() async {
      final response = await _fetchExchangeRates();
      return response;
    });
  }

  Future<CurrencyResponse> _fetchExchangeRates() async {
    // Check if we have a cached response that is newer than 30 minutes
    final cachedResponse = await cachedResponseCheck();
    if (cachedResponse != null) {
      return cachedResponse.response;
    }

    final response = await _httpClient.get(
      Uri.parse('$_baseApiPath/live?access_key=$_accessApiKey'),
    );

    if (response.statusCode == 200) {
      _cachedResponse = LocalCacheModel(
        response: CurrencyResponse.fromJson(json.decode(response.body)),
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      (await _getPrefs).setString(
        _prefResponseCacheKey,
        json.encode(_cachedResponse!.toJson()),
      );
      return _cachedResponse!.response;
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }
}

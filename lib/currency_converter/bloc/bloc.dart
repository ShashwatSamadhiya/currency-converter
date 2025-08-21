import 'package:bloc/bloc.dart';
import 'package:currency_converter/currency_converter/app.dart';

import 'package:currency_converter/currency_converter/bloc/events.dart';
import 'package:currency_converter/currency_converter/bloc/states.dart';
import 'package:currency_converter/currency_converter/models/currency_rate_response.dart';
import 'package:flutter/foundation.dart';

class CurrencyConverterBloc
    extends Bloc<CurrencyConverterEvent, CurrencyConverterState> {
  final CurrencyConverterApi api;
  CurrencyConverterBloc(this.api)
    : super(CurrencyConverterInitialState(CurrencyConverterInitialEvent())) {
    on((event, emit) async {
      if (event is CurrencyConverterExchangeRatesList) {
        await _onListEvent(event, emit);
      } else if (event is CurrencyConverterBaseCurrencyAndAmountChange) {
        await _onBaseCurrencyOrAmountChange(event, emit);
      }
    });
  }

  double convert(
    CurrencyResponse response,
    double amount,
    String from,
    String to,
  ) {
    final fromRate = response.getExchangeRate(from);
    final toRate = response.getExchangeRate(to);

    assert(fromRate != 0, 'From rate cannot be zero');

    return (amount / fromRate) * toRate;
  }

  Future<void> _onBaseCurrencyOrAmountChange(
    CurrencyConverterBaseCurrencyAndAmountChange event,
    Emitter<CurrencyConverterState> emit,
  ) async {
    emit(CurrencyConverterLoadingState(event));
    final response = await api.fetchExchangeRates();
    for (var rates in response.quotes) {
      rates.changedRateForCurrency = convert(
        response,
        event.amount,
        event.currency,
        rates.symbol,
      );
    }
    emit(
      CurrencyConverterBaseCurrencyChangedState(
        event,
        response,
        event.currency,
        amount: event.amount,
      ),
    );
  }

  Future<void> _onListEvent(
    CurrencyConverterEvent event,
    Emitter<CurrencyConverterState> emit,
  ) async {
    try {
      emit(CurrencyConverterLoadingState(event));

      final response = await api.fetchExchangeRates();

      emit(CurrencyConverterLoadedState(event, response));
    } catch (error, stackTrace) {
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      emit(CurrencyConverterErrorState(event, error));
    }
  }
}

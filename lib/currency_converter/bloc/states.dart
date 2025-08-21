import 'package:currency_converter/currency_converter/bloc/events.dart';
import 'package:currency_converter/currency_converter/models/currency_rate_response.dart';
import 'package:equatable/equatable.dart';

/// Base class for all currency converter states.
abstract class CurrencyConverterState extends Equatable {
  // Underlying event for which this state was emitted.
  final CurrencyConverterEvent event;
  const CurrencyConverterState(this.event);

  @override
  List<Object> get props => [event];
}

/// State representing the initial state of the currency converter.
class CurrencyConverterInitialState extends CurrencyConverterState {
  const CurrencyConverterInitialState(super.event);
}

/// State representing the loading state of the currency converter.
class CurrencyConverterLoadingState extends CurrencyConverterState {
  const CurrencyConverterLoadingState(super.event);
}

/// State representing the loaded state with exchange rates.
class CurrencyConverterLoadedState extends CurrencyConverterState {
  final CurrencyResponse exchangeRates;

  const CurrencyConverterLoadedState(super.event, this.exchangeRates);

  @override
  List<Object> get props => [event, exchangeRates];
}

/// State representing an error state in the currency converter.
class CurrencyConverterErrorState extends CurrencyConverterState {
  final Object error;

  const CurrencyConverterErrorState(super.event, this.error);
}

/// State representing a change in the base currency.
/// This state is triggered when the user selects a different base currency.
class CurrencyConverterBaseCurrencyChangedState extends CurrencyConverterState {
  final String currency;
  final double amount;
  final CurrencyResponse exchangeRates;

  const CurrencyConverterBaseCurrencyChangedState(
    super.event,
    this.exchangeRates,
    this.currency, {
    this.amount = 1.0, // Default amount if not specified
  });

  @override
  List<Object> get props => [event, currency, amount];
}

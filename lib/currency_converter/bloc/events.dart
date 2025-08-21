import 'package:equatable/equatable.dart';

/// Base class for all currency converter events.
/// It extends Equatable to enable value comparison between instances.
abstract class CurrencyConverterEvent extends Equatable {
  const CurrencyConverterEvent();

  @override
  List<Object> get props => [];
}

/// Initial event for the currency converter.
/// This event is triggered when the application starts or when the bloc is initialized.
class CurrencyConverterInitialEvent extends CurrencyConverterEvent {}

/// Event to fetch exchange rates.
/// This event is triggered when the application needs to list the exchange rates
class CurrencyConverterExchangeRatesList extends CurrencyConverterEvent {}

/// Event to change the base currency.
/// This event is triggered when the user selects a different base currency
/// to see the exchange rates against that currency.
class CurrencyConverterBaseCurrencyAndAmountChange
    extends CurrencyConverterEvent {
  final String currency;
  final double amount;

  const CurrencyConverterBaseCurrencyAndAmountChange(
    this.currency, {
    this.amount = 1,
  });

  @override
  List<Object> get props => [currency, amount];
}

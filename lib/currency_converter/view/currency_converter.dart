import 'dart:async';

import 'package:currency_converter/currency_converter/bloc/bloc.dart';
import 'package:currency_converter/currency_converter/bloc/events.dart';
import 'package:currency_converter/currency_converter/bloc/states.dart';
import 'package:currency_converter/currency_converter/models/quotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CurrencyConverterScreen(),
    );
  }

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _decimalRegex = RegExp(r'^\d*\.?\d*$');
  String _selectedCurrency = 'USDUSD';
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.text = '1'; // Default amount to 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calCulateExchangeRates();
    });
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _calCulateExchangeRates() {
    final amount = double.tryParse(_controller.text) ?? 1.0;
    context.read<CurrencyConverterBloc>().add(
      CurrencyConverterBaseCurrencyAndAmountChange(
        _selectedCurrency,
        amount: amount,
      ),
    );
  }

  /// Debounce function to handle user input changes
  /// This prevents multiple rapid calls to the bloc when the user is typing.
  void _onChanged(String value) {
    // cancel old timer if user is still typing
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // wait 500ms after user stops typing
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _calCulateExchangeRates();
    });
  }

  Widget enterAmountTextField() {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          return _decimalRegex.hasMatch(newValue.text) ? newValue : oldValue;
        }),
      ],
      decoration: const InputDecoration(
        hintText: "Enter amount",
        prefixIcon: Icon(Icons.monetization_on, color: Colors.amber),
        hintStyle: TextStyle(color: Colors.grey),
      ),
      onChanged: _onChanged,
    );
  }

  Widget headingText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.amberAccent,
      ),
    );
  }

  Widget exchangeRatesTiles(Quote exchangeRates) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.amber.withValues(alpha: 0.2),
        child: Text(
          exchangeRates.targetCurrency.substring(0, 1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ),
      title: Text(
        exchangeRates.targetCurrency,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        exchangeRates.changedRateForCurrency.toStringAsFixed(4),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.amberAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget dropDownCurrencySelector(
    List<Quote> currencies,
    String selectedCurrency,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCurrency,
          dropdownColor: Colors.grey[900],
          isExpanded: true,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          items:
              currencies.map((Quote currency) {
                return DropdownMenuItem<String>(
                  value: currency.symbol,
                  child: Text(
                    currency.targetCurrency,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue == null) return;
            if (mounted) {
              setState(() {
                _selectedCurrency = newValue;
              });
            }
            _calCulateExchangeRates();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("💱 Currency Converter")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
          builder: (context, state) {
            if (state is CurrencyConverterBaseCurrencyChangedState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dropDownCurrencySelector(
                    state.exchangeRates.quotes,
                    state.currency,
                  ),
                  const SizedBox(height: 20),
                  enterAmountTextField(),
                  const SizedBox(height: 20),
                  headingText("Converted Rates"),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final exchangeRate = state.exchangeRates.quotes[index];
                        return exchangeRatesTiles(exchangeRate);
                      },
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 20),
                      itemCount: state.exchangeRates.quotes.length,
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

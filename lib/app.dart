import 'package:currency_converter/currency_converter/app.dart';
import 'package:currency_converter/currency_converter/bloc/bloc.dart';
import 'package:currency_converter/currency_converter/bloc/events.dart';
import 'package:currency_converter/currency_converter/bloc/states.dart';
import 'package:currency_converter/currency_converter/view/currency_converter.dart';
import 'package:currency_converter/currency_converter/view/error.dart';
import 'package:currency_converter/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              CurrencyConverterBloc(CurrencyConverterApi())
                ..add(CurrencyConverterExchangeRatesList()),
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      builder: (context, child) {
        return BlocListener<CurrencyConverterBloc, CurrencyConverterState>(
          listener: (context, state) {
            if (state is CurrencyConverterLoadedState) {
              _navigator.pushAndRemoveUntil<void>(
                CurrencyConverterScreen.route(),
                (route) => false,
              );
            } else if (state is CurrencyConverterErrorState) {
              _navigator.pushAndRemoveUntil<void>(
                ErrorPage.route(),
                (route) => false,
              );
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}

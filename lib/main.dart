import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../blocs/bank/bank_bloc.dart';
import '../screens/library_screen/library_screen.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setMinimumSize(Constants.minimumWindowSize);
  DartVLC.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            for (final platform in TargetPlatform.values)
              platform: const ZoomPageTransitionsBuilder(),
          },
        ),
        checkboxTheme: CheckboxThemeData(
            splashRadius: 0.0,
            checkColor: MaterialStateProperty.all(Colors.black),
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return Constants.selectedColor;
              } else {
                return Constants.buttonBackgroundColor;
              }
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.tightBorderRadius),
            )),
        buttonTheme: ButtonThemeData(
          minWidth: Constants.minButtonWidth,
          height: Constants.minButtonHeight,
          padding: const EdgeInsets.all(4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.borderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Constants.buttonBackgroundColor,
            onPrimary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Constants.buttonBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Constants.buttonBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          constraints: const BoxConstraints(
            minHeight: Constants.minButtonHeight,
            maxHeight: Constants.minButtonHeight,
          ),
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          color: Constants.buttonUnfocusedTextColor,
          selectedColor: Colors.black,
          fillColor: Constants.selectedColor,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
              color: Constants.selectedColor,
              borderRadius: BorderRadius.circular(Constants.borderRadius)),
          textStyle: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Instantiate the bloc and call the initial event.
      create: (_) => BankBloc()..add(LoadInitialBank()),
      child: const LibraryScreen(),
    );
  }
}

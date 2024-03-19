import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:omegainc_lib/omegalibconfig.dart';

import 'consts/consts.dart';
import 'views/home.view.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MyApp()));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    OmegaLibConfig.enabledBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Consts.primaryColor, width: 0.0),
      borderRadius: BorderRadius.all(Radius.circular(10.5)),
    );

    OmegaLibConfig.focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 0.0),
      borderRadius: BorderRadius.all(Radius.circular(10.5)),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Consts.appTitle,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeView(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("pt"),
        Locale("pt_BR"),
      ],
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: false,
      ),
    );
  }
}

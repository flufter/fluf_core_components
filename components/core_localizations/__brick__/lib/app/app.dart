import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/l10n/l10n.dart';
import 'package:flutter/services.dart';

// Define color variables
final Color pinkColor = const Color(0xFFDA79E5);
final Color purpleColor = const Color(0xFF6139F7);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '{{project_name.titleCase()}}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: purpleColor),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MyHomePage(title: '{{project_name.titleCase()}}'),
      builder: (context, child) {
        return Banner(
          message: 'Fluf',
          location: BannerLocation.topEnd,
          color: pinkColor,
          shadow: const BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
          child: child!,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  // Maximum alpha value for gradients (255 = fully opaque)
  final int _maxAlpha = 255;
  // Initial alpha values for gradients (reduced to start more transparent)
  final int _initialPinkAlpha = 80;
  final int _initialPurpleAlpha = 80;
  // Initial opacity for the image (starts nearly invisible)
  final double _initialImageOpacity = 0.00;

  // Calculate alpha value based on counter
  int _calculateAlpha(int baseAlpha) {
    // Exponential function that makes it harder to reach full opacity as counter increases
    // Will approach but never exceed _maxAlpha
    double progress = 1 - math.exp(-_counter / 50);
    return baseAlpha + (((_maxAlpha - baseAlpha) * progress).toInt());
  }

  // Calculate image opacity based on counter
  double _calculateImageOpacity() {
    // Similar exponential function for image opacity
    // Will approach but never reach 1.0 (fully opaque)
    double progress = 1 - math.exp(-_counter / 100);
    return _initialImageOpacity + ((1.0 - _initialImageOpacity) * progress);
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _decrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate current alpha values based on counter
    final int pinkAlpha = _calculateAlpha(_initialPinkAlpha);
    final int purpleAlpha = _calculateAlpha(_initialPurpleAlpha);
    // Calculate current image opacity
    final double imageOpacity = _calculateImageOpacity();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: purpleColor.withAlpha(1 - purpleAlpha),
        actions: [
          IconButton(
            onPressed: () => showLocalizationDialog(context),
            icon: const Icon(Icons.language),
          ),
        ],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          // Background gradient with dynamic alpha
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  pinkColor.withAlpha(pinkAlpha),
                  pinkColor.withAlpha(0),
                ],
                stops: const [0.1, 0.85],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.2,
                colors: [
                  purpleColor.withAlpha(purpleAlpha),
                  purpleColor.withAlpha(10),
                ],
                stops: const [0.1, 0.95],
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.65),
            child: Opacity(
              opacity: imageOpacity,
              child: Image.asset(
                'assets/images/app_icon/android_app_icon_adaptive_foreground.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(context.l10n.youHavePushedTheButtonThisManyTimes),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: _counter > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: _counter <= 0,
              child: FloatingActionButton(
                onPressed: _decrementCounter,
                tooltip: 'Decrement',
                child: const Icon(Icons.remove),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void showLocalizationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(child: Text('Localization Example')),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Placeholder example
            const Text(
              'Placeholder Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(context.l10n.hello('John')),
            ),

            // 2. Plural example
            const Text(
              'Plural Examples:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.nWombats(0)),
                  Text(context.l10n.nWombats(1)),
                  Text(context.l10n.nWombats(5)),
                ],
              ),
            ),

            // 3. Select/Gender example
            const Text(
              'Select/Gender Examples:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.pronoun('male')),
                  Text(context.l10n.pronoun('female')),
                  Text(context.l10n.pronoun('other')),
                ],
              ),
            ),

            // 4. Number formatting example
            const Text(
              'Number Formatting Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(context.l10n.numberOfDataPoints(1200000)),
            ),

            // 5. Date formatting example
            const Text(
              'Date Formatting Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                context.l10n.helloWorldOn(DateTime.utc(1959, 7, 9)),
              ),
            ),

            // 6. Escaping syntax example
            const Text(
              'Escaping Syntax Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(context.l10n.escapedExample),
            ),
          ],
        ),
      ),
    ),
  );
}

import 'dart:io';

import 'package:eWellness/config.dart';
import 'package:flutter/material.dart';
import 'package:eWellness/views/ServiceReservationScreen.dart';
import 'package:eWellness/views/LoginScreen.dart';
import 'package:eWellness/views/RegistrationScreen.dart';
import 'package:eWellness/views/StripePaymentScreen.dart'; // Import the Stripe payment screen
import 'package:eWellness/views/TipsTricksScreen.dart';
import 'package:eWellness/views/SpecialOffersScreen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Stripe.publishableKey = stripePublishableKey;
    Stripe.merchantIdentifier = 'eWellness';
    await Stripe.instance.applySettings();
  } catch (ex) {
    print(ex);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eWellness',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/tips': (context) => TipsTricksScreen(),
        '/discounts': (context) => SpecialOffersScreen(),
        '/reservation': (context) => ServiceReservationScreen(),
        '/login': (context) => LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        // '/payment': (context) => StripePaymentScreen()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    setState(() {
      isLoggedIn = userId != null && userId != -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('eWellness'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://t4.ftcdn.net/jpg/00/99/47/49/360_F_99474971_kvwn04WzYNdXntumZ4ajbDYyfOpKxUoX.jpg',
              fit: BoxFit.cover,
              height: 200,
            ),
            Text(
              'Welcome to eWellness!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            if (isLoggedIn) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 175, 142),
                  elevation: 5,
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/tips');
                },
                child: Text('Tips & Tricks'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 175, 142),
                  elevation: 5,
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/discounts');
                },
                child: Text('Discounts'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 175, 142),
                  elevation: 5,
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/reservation');
                },
                child: Text('Service Reservation'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Logout functionality
                  setState(() {
                    isLoggedIn = false;
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.remove('userId');
                    });
                  });
                },
                child: Text('Logout'),
              ),
            ],
            if (!isLoggedIn) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 175, 142),
                  elevation: 5,
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  elevation: 0,
                  foregroundColor: Color.fromARGB(255, 76, 175, 142),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/registration');
                },
                child: Text('New to our services? Register'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

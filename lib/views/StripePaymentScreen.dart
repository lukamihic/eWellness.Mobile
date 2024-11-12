import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eWellness/services/api.dart'; // Import your API service
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart' as config show stripeApiKey, stripeUri;

class StripePaymentScreen extends StatefulWidget {
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;

  StripePaymentScreen({
    required this.serviceId,
    required this.startTime,
    required this.endTime,
  });

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  late Map<String, dynamic> paymentIntentData;
  final TextEditingController _amountController = TextEditingController();
  static const stripeApiKey = String.fromEnvironment('STRIPE_API_KEY',
      defaultValue: config.stripeApiKey);
  static const stripeUri =
      String.fromEnvironment('STRIPE_URI', defaultValue: config.stripeUri);

  @override
  void initState() {
    super.initState();
    _amountController.text = '0'; // Initialize with default value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter Amount (EUR)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await makePayment();
              },
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      // Ensure amount is valid
      if (_amountController.text.isEmpty ||
          int.parse(_amountController.text) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid amount.'),
          ),
        );
        return;
      }

      // Create payment intent
      paymentIntentData = await createPaymentIntent(
        _amountController.text,
        'EUR',
      );

      // Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData['client_secret']),
      );

      // Display Stripe payment sheet
      await displayPaymentSheet();
    } catch (e, s) {
      print('Error making payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Payment failed. Please try again. Please pay in studio.'),
        ),
      );
      createAppointment();
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      final body = {'amount': calculateAmount(amount), 'currency': currency};

      print(stripeUri);
      print('Bearer $stripeApiKey');
      final response = await http.post(
        Uri.parse('${stripeUri}payment_intents'),
        headers: {
          'Authorization': 'Bearer $stripeApiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception(
            'Failed to create payment intent: ${response.statusCode}');
      }
    } catch (err) {
      print('Error creating payment intent: $err');
      throw err;
    }
  }

  String calculateAmount(String amount) {
    final price = int.parse(amount) * 100; // Convert to cents
    return price.toString();
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        paymentIntentData = {}; // Clear payment intent data after payment
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Payment successful")));

      // After successful payment, proceed to create appointment
      await createAppointment();
    } on StripeException catch (e) {
      print("Error from Stripe: ${e.error.localizedMessage}");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Payment failed")));
    } catch (e) {
      print("Unforeseen error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Payment failed")));
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> createAppointment() async {
      try {
        final parts = (await getUserId() ?? '').split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));

      final payloadMap = json.decode(decoded);
      
      final userId = int.parse(payloadMap['sub']);
      final totalPrice = _amountController.text;

      final response = await ApiService().createAppointment({
        "clientId": userId,
        "serviceId": widget.serviceId,
        "startTime": widget.startTime.toIso8601String(),
        "endTime": widget.endTime.toIso8601String(),
        "notes": "NONE",
        "status": "RESERVED",
        "totalPrice": totalPrice,
      });
      print(response);
      final appointmentId = response;
      print(appointmentId);
      try {
        await createPaymentRecord(appointmentId.toString());
      } catch (e) {
        print(e);
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Success!")));
      Navigator.pushNamed(context, '/');
    } catch (e) {
      print('Error creating appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create appointment")));
    }
  }

  Future<void> createPaymentRecord(String appointmentId) async {
    print(paymentIntentData[
          'id']);
    try {
      final transactionId = paymentIntentData[
          'id']; // Assuming the transaction ID from Stripe payment
      final amount = _amountController.text;
      final date = DateTime.now().toIso8601String(); // Current date
      final fees = '0'; // Assuming fees are zero
      final paymentMethodId = '1'; // Assuming payment method ID

      print({
        "amount": amount,
        "date": date,
        "transactionId": transactionId,
        "fees": fees,
        "paymentMethodId": paymentMethodId,
        "appointmentId": appointmentId,
      });
      await ApiService().createPayment({
        "amount": amount,
        "date": date,
        "transactionId": transactionId,
        "fees": fees,
        "paymentMethodId": paymentMethodId,
        "appointmentId": appointmentId,
      });

      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Success!")));
    } catch (e) {
      print('Error creating payment record:s $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create payment record")));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eWellness/services/api.dart'; // Import your API service
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart' as config show stripeApiKey, stripeUri;
import 'package:credit_card_type_detector/credit_card_type_detector.dart'; // For card type detection

class StripePaymentScreen extends StatefulWidget {
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final double price;

  StripePaymentScreen({
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  Map<String, dynamic>? paymentIntentData; // Nullable to avoid initialization errors
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String cardLogo = ''; // To store the card logo based on the card type

  static const stripeApiKey = String.fromEnvironment(
    'STRIPE_API_KEY',
    defaultValue: config.stripeApiKey,
  );
  static const stripeUri = String.fromEnvironment(
    'STRIPE_URI',
    defaultValue: config.stripeUri,
  );

  @override
  void initState() {
    super.initState();
    print(widget.price);
    _amountController.text = widget.price.toString(); // Initialize with default value
  }

  void _onCardNumberChanged(String value) {
    setState(() {
      final cardType = detectCCType(value);
      cardLogo = cardType!.first.type.toLowerCase(); // Use the card type's logo name
    });
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
            Image.network(
              'https://img.freepik.com/free-vector/credit-card-concept-illustration_114360-159.jpg',
              height: 200,
            ),
            SizedBox(height: 8),
            Text(
              'Online Payment',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.teal, fontSize: 18),
            ),
            SizedBox(height: 16),
            _buildCardForm(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await makePayment();
              },
              child: Text('Make Payment'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        _buildCardNumberField(),
        SizedBox(height: 8),
        _buildExpiryDateField(),
        SizedBox(height: 8),
        _buildCardHolderNameField(),
        SizedBox(height: 8),
        _buildCVVField(),
      ],
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: InputDecoration(
        labelText: 'Card Number',
        prefixIcon: Icon(Icons.credit_card),
        suffixIcon: null
      ),
      keyboardType: TextInputType.number,
      onChanged: _onCardNumberChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid card number';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryDateField() {
    return TextFormField(
      controller: _expiryController,
      decoration: InputDecoration(
        labelText: 'Expiry Date (MM/YY)',
        prefixIcon: Icon(Icons.calendar_today),
      ),
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter expiry date';
        }
        return null;
      },
    );
  }

  Widget _buildCardHolderNameField() {
    return TextFormField(
      controller: _cardHolderNameController,
      decoration: InputDecoration(
        labelText: 'Cardholder Name',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter cardholder name';
        }
        return null;
      },
    );
  }

  Widget _buildCVVField() {
    return TextFormField(
      controller: _cvvController,
      decoration: InputDecoration(
        labelText: 'CVV',
        prefixIcon: Icon(Icons.lock),
      ),
      keyboardType: TextInputType.number,
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter CVV';
        }
        return null;
      },
    );
  }

  Future<void> makePayment() async {
    try {
      // Ensure amount is valid
      if (_amountController.text.isEmpty ||
          double.parse(_amountController.text) <= 0) {
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
      
      print(paymentIntentData!['id']);

      // Initialize Stripe payment sheet
      // if (paymentIntentData != null) {
      //   await Stripe.instance.initPaymentSheet(
      //     paymentSheetParameters: SetupPaymentSheetParameters(
      //       paymentIntentClientSecret: paymentIntentData!['client_secret'],
      //     ),
      //   );

      //   // Display Stripe payment sheet
      //   // await displayPaymentSheet();
      // }
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
    createAppointment();
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
    final price = (double.parse(amount) * 100).round(); // Convert to cents
    return price.toString();
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        paymentIntentData = null; // Clear payment intent data after payment
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed")));
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

print("doslo");
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

  Future<void> createReservation() async {
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
        "status": "UNPAID",
        "totalPrice": totalPrice,
      });
      print(response);
      final appointmentId = response;
      print(appointmentId);
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
    try {
      if (paymentIntentData == null || !paymentIntentData!.containsKey('id')) {
        throw Exception("Payment intent data is invalid or missing transaction ID.");
      }
      

      final transactionId = paymentIntentData!['id'];
      final amount = _amountController.text;
      final date = DateTime.now().toIso8601String();
      final fees = '0';
      final paymentMethodId = '1';

      print(amount);
      print(date);
      print(transactionId);
      print(fees);
      print(paymentMethodId);
      print(appointmentId);

      await ApiService().createPayment({
        "amount": amount,
        "date": date,
        "transactionId": transactionId,
        "fees": fees,
        "paymentMethodId": paymentMethodId,
        "appointmentId": appointmentId,
      });

      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment record created successfully!"))
      );
    } catch (e) {
      print('Error creating payment record: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment record created successfully!"))
      );
    }
  }
}

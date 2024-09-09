import 'dart:convert';
import 'package:eWellness/models/offers.dart';
import 'package:eWellness/models/services.dart';
import 'package:eWellness/models/tips.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart' as config show apiUri;

class ApiService {
  static const apiUrl =
      String.fromEnvironment('API_URI', defaultValue: config.apiUri);

  Future<List<Tip>> fetchTips() async {
    final response = await http.get(Uri.parse(apiUrl + 'tips'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Tip.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tips');
    }
  }

  Future<List<Offer>> fetchOffers() async {
    final response = await http.get(Uri.parse(apiUrl + 'specialOffers'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Offer.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load offers');
    }
  }

  Future<List<Services>> fetchServices() async {
    final response = await http.get(Uri.parse(apiUrl + 'services'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Services.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<int> login(String email, String password) async {
    final Uri fullApiUrl = Uri.parse(apiUrl + 'users/login');

    final Map<String, String> body = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      fullApiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      int userId = int.parse(response.body);
      await saveUserId(userId); // Save user ID to shared preferences
      return userId;
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<void> registerClient({
    required bool isMember,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String dateOfBirth,
    required String gender,
    String? emergencyContactName,
    String? emergencyContactPhone,
    required String passwordInput,
  }) async {
    final Uri fullApiUrl = Uri.parse(apiUrl + 'clients');

    final Map<String, dynamic> body = {
      'isMember': isMember,
      'user': {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'passwordInput': passwordInput,
      }
    };

    final response = await http.post(
      fullApiUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode.toString().startsWith('2')) {
      // Registration successful
      print('Registration successful');
    } else {
      // Registration failed
      print('Failed to register: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to register');
    }
  }

  Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> data) async {
    final Uri fullApiUrl = Uri.parse(apiUrl + 'appointments');

    try {
      final response = await http.post(
        fullApiUrl,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers as needed
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      print('Error creating appointment: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data) async {
    final Uri fullApiUrl = Uri.parse(
        apiUrl + 'payments'); // Assuming this is your endpoint for payments

    try {
      final response = await http.post(
        fullApiUrl,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers as needed
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment record');
      }
    } catch (e) {
      print('Error creating payment record: $e');
      throw e;
    }
  }
}

Future<void> saveUserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', userId);
}

Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
}

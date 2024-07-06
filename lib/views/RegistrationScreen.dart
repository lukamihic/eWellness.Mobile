import 'package:flutter/material.dart';
import 'package:eWellness/services/api.dart'; // Import your API service

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  bool _consentChecked = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emergencyContactNameController =
      TextEditingController();
  TextEditingController _emergencyContactPhoneController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text('Gender: '),
                    Radio<String>(
                      value: 'M',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    Text('Male'),
                    Radio<String>(
                      value: 'F',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    Text('Female'),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emergencyContactNameController,
                  decoration:
                      InputDecoration(labelText: 'Emergency Contact Name'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emergencyContactPhoneController,
                  decoration:
                      InputDecoration(labelText: 'Emergency Contact Phone'),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _consentChecked,
                      onChanged: (value) {
                        setState(() {
                          _consentChecked = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'I consent to the use of my data as outlined in the privacy policy.',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _consentChecked ? _register : null,
                  child: Text('Finish Registration'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      backgroundColor: const Color.fromARGB(255, 76, 175, 142),
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService().registerClient(
          isMember: true, // Example value, adjust as needed
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          dateOfBirth: DateTime.now()
              .toIso8601String(), // Example date format, adjust as needed
          gender: _gender ?? '', // Ensure gender is not null
          emergencyContactName: _emergencyContactNameController.text.isEmpty
              ? null
              : _emergencyContactNameController.text,
          emergencyContactPhone: _emergencyContactPhoneController.text.isEmpty
              ? null
              : _emergencyContactPhoneController.text,
          passwordInput: _passwordController.text,
        );

        // Registration successful, navigate to home screen or any other screen
        Navigator.pop(context); // Close registration screen
        // Navigate to home screen
        Navigator.pushReplacementNamed(
            context, '/'); // Replace with your home screen route
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration success.'),
          ),
        );
      } catch (e) {
        // Handle registration error
        print('Registration error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed. Please try again.'),
          ),
        );
      }
    }
  }
}

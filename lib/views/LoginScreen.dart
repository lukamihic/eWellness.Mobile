import 'package:eWellness/preference_utils.dart';
import 'package:eWellness/services/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "eWellness",
              style: TextStyle(
                fontSize: 24.0, // Specify the font size here
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text;
                String password = passwordController.text;
                ApiService().login(email, password).then((userId) {
                  setId(userId);
                  Navigator.pushNamed(context, '/'); // Navigate to home screen
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Login success!")));
                }).catchError((error) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Login failed!")));
                }).catchError((error) {});
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                backgroundColor: const Color.fromARGB(255, 76, 175, 142),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> setId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('userId', id);
}

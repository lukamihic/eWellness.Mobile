import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/tips.dart';

class TipsTricksScreen extends StatefulWidget {
  @override
  _TipsTricksScreenState createState() => _TipsTricksScreenState();
}

class _TipsTricksScreenState extends State<TipsTricksScreen> {
  late Future<List<Tip>> futureTips;

  @override
  void initState() {
    super.initState();
    futureTips = ApiService().fetchTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tips & Tricks'),
      ),
      body: FutureBuilder<List<Tip>>(
        future: futureTips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tips available'));
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.teal,
                        size: 64,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ...snapshot.data!.map((tip) => buildTipCard(tip)).toList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildTipCard(Tip tip) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              tip.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

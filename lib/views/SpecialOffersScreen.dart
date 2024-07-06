import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/offers.dart';

class SpecialOffersScreen extends StatefulWidget {
  @override
  _SpecialOffersScreenState createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends State<SpecialOffersScreen> {
  late Future<List<Offer>> futureOffers;

  @override
  void initState() {
    super.initState();
    futureOffers = ApiService().fetchOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Special Offers'),
      ),
      body: FutureBuilder<List<Offer>>(
        future: futureOffers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No offers available'));
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
                        Icons.percent,
                        color: Colors.teal,
                        size: 64,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ...snapshot.data!
                      .map((offer) => buildOfferCard(offer))
                      .toList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildOfferCard(Offer tip) {
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

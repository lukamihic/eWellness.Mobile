import 'package:eWellness/views/StripePaymentScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eWellness/services/api.dart'; // Import your API service
import './StripePaymentScreen.dart';

class ServiceReservationScreen extends StatefulWidget {
  @override
  _ServiceReservationScreenState createState() =>
      _ServiceReservationScreenState();
}

class _ServiceReservationScreenState extends State<ServiceReservationScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? selectedServiceId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> recommendedServices = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchRecommendedServices();
  }

  Future<void> _fetchServices() async {
    try {
      final data = await ApiService().fetchServices(); // Call the API method
      setState(() {
        services = data
            .map((item) =>
                {'id': item.id, 'title': item.title, 'price': item.price})
            .toList();
      });
    } catch (e) {
      print('Failed to load services: $e');
      // Handle error appropriately, e.g., show a Snackbar or Dialog
    }
  }

  Future<void> _fetchRecommendedServices() async {
    try {
      final data =
          await ApiService().fetchRecommendedServices(); // Call the API method
      setState(() {
        recommendedServices = data
            .map((item) =>
                {'id': item.id, 'title': item.title, 'price': item.price})
            .toList();
      });
    } catch (e) {
      print('Failed to load services: $e');
      // Handle error appropriately, e.g., show a Snackbar or Dialog
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text = DateFormat.yMd().format(selectedDate!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, selectedTime!.hour,
            selectedTime!.minute);
        _timeController.text = DateFormat.Hm().format(dt);
      });
    }
  }

  void _confirmReservation() {
    if (selectedServiceId != null &&
        selectedDate != null &&
        selectedTime != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StripePaymentScreen(
            serviceId: selectedServiceId!,
            startTime: selectedDate!,
            endTime: DateTime(selectedDate!.year, selectedDate!.month,
                selectedDate!.day, 23, 59),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a service, date, and time.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Reservation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedServiceId,
              hint: Text('Select a Service'),
              items: services.map((service) {
                return DropdownMenuItem<String>(
                  value: service['id'].toString(),
                  child: Text('${service['title']} - BAM ${service['price']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedServiceId = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Select Date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Select Time',
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _confirmReservation,
                child: Text('Confirm Reservation'),
              ),
            ),
            SizedBox(height: 24.0),
            Center(
              child: Text(recommendedServices.length > 0
                  ? "We recommend ${services.first['title']}"
                  : "Make a first reservation to get recommendations from us!"),
            ),
          ],
        ),
      ),
    );
  }
}

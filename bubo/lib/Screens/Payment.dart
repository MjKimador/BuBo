import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _paymentStatus = 'Ready to initiate payment';
  String _redirectUrl = '';
  bool _isLoading = false;

  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    // Establish a WebSocket connection
    _channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://localhost:30343/'), // Make sure to use the correct address
    );

    // Listen for messages from the server
    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['redirectUrl'] != null) {
        setState(() {
          _redirectUrl = data['redirectUrl'];
          _paymentStatus =
              'Redirect URL received. Please complete the payment.';
        });
      } else if (data['status'] != null) {
        setState(() {
          _paymentStatus = data['status'];
        });
      }
    });
  }

  Future<void> _initiatePayment() async {
    if (_senderController.text.isEmpty ||
        _receiverController.text.isEmpty ||
        _amountController.text.isEmpty) {
      setState(() {
        _paymentStatus = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _paymentStatus = 'Initiating payment...';
    });

    try {
      // Send data to the server
      _channel.sink.add(jsonEncode({
        'sendWallet': _senderController.text,
        'receiverWallet': _receiverController.text,
        'amountMoney': _amountController.text,
      }));

      // You might want to set a timeout or a way to confirm payment completion here
    } catch (e) {
      setState(() {
        _isLoading = false;
        _paymentStatus = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close(); // Close the WebSocket channel when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 71, 69, 69),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _senderController,
              decoration: InputDecoration(
                labelText: 'Sender Wallet',
                labelStyle: TextStyle(color: Colors.cyan),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _receiverController,
              decoration: InputDecoration(
                labelText: 'Receiver Wallet',
                labelStyle: TextStyle(color: Colors.cyan),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.cyan),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _initiatePayment,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Initiate Payment', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 24),
            Text(
              _paymentStatus,
              style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_redirectUrl.isNotEmpty) ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Here you would typically launch the URL
                  print('Opening redirect URL: $_redirectUrl');
                },
                child: Text('Complete Payment', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 61, 59, 59),
    );
  }
}

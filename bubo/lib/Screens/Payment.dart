import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _paymentCompleted = false;

  late WebSocketChannel _channel;

  // HashMap to store wallet addresses
  final Map<String, String> _walletMap = {
    '1234': 'b40ce34e-5db6-487a-abdd-d1a93e9f9457', // sendWallet
    '5678': '247e60e4-a5aa-4291-a5b6-2b2389662d91', // receiverWallet
  };

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:30343/'),
    );

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['redirectUrl'] != null) {
        setState(() {
          _redirectUrl = data['redirectUrl'];
          _paymentStatus =
              'Authorization URL received. Please complete the payment.';
        });
      } else if (data['status'] != null) {
        setState(() {
          _paymentStatus = data['status'];
          if (data['status'] == 'Payment completed successfully') {
            _paymentCompleted = true;
          }
        });
      }
    });
  }

  String _getWalletAddress(String key) {
    return _walletMap[key] ?? '';
  }

  Future<void> _initiatePayment() async {
    String senderWallet = _getWalletAddress(_senderController.text);
    String receiverWallet = _getWalletAddress(_receiverController.text);

    if (senderWallet.isEmpty ||
        receiverWallet.isEmpty ||
        _amountController.text.isEmpty) {
      setState(() {
        _paymentStatus = 'Please enter valid wallet keys and amount';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _paymentStatus = 'Initiating payment...';
    });

    try {
      _channel.sink.add(jsonEncode({
        'sendWallet': senderWallet,
        'receiverWallet': receiverWallet,
        'amountMoney': _amountController.text,
      }));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _paymentStatus = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _launchAuthorizationURL() async {
    if (_redirectUrl.isNotEmpty) {
      if (await canLaunch(_redirectUrl)) {
        await launch(_redirectUrl);
      } else {
        setState(() {
          _paymentStatus = 'Could not launch $_redirectUrl';
        });
      }
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
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
        child: _paymentCompleted ? _buildThankYouWidget() : _buildPaymentForm(),
      ),
      backgroundColor: Color.fromARGB(255, 61, 59, 59),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _senderController,
          decoration: InputDecoration(
            labelText: 'Sender Wallet Key (4 digits)',
            labelStyle: TextStyle(color: Colors.cyan),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
        SizedBox(height: 16),
        TextField(
          controller: _receiverController,
          decoration: InputDecoration(
            labelText: 'Receiver Wallet Key (4 digits)',
            labelStyle: TextStyle(color: Colors.cyan),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          maxLength: 4,
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
            onPressed: _launchAuthorizationURL,
            child: Text('Authorize Payment', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThankYouWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
          SizedBox(height: 24),
          Text(
            'Thank You!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Your payment has been completed successfully.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

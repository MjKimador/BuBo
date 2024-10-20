import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:bubo/Screens/budget_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentMethodsPage extends StatefulWidget {
  Budget budget;
  final Function(Budget) onBudgetUpdated;

  PaymentMethodsPage({required this.budget, required this.onBudgetUpdated});

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String email = '';
  String name = '';
  String affiliationNumber = '';
  String amountToPay = '';
  String paymentType = 'Card'; // Default payment type
  String sender = "b40ce34e-5db6-487a-abdd-d1a93e9f9457";

  static const String SERVER_URL = 'http://192.168.56.1:33335';

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    socket = IO.io(SERVER_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('Connection established');
    });

    socket.onDisconnect((_) {
      print('Connection disconnected');
    });

    socket.onConnectError((err) {
      print('Connect error: $err');
      _showErrorDialog('Failed to connect to server: $err');
    });

    socket.onError((err) {
      print('Error: $err');
      _showErrorDialog('An error occurred: $err');
    });

    socket.connect();
  }

  Future<void> _handlePayment() async {
    if (!socket.connected) {
      _showErrorDialog('Not connected to server');
      return;
    }

    // Prepare data to send
    final dataToSend = {
      'senderWallet': sender,
      'receiverWallet': email,
      'amount': amountToPay,
    };

    socket.emit('initiate-payment', dataToSend);
    print('Sent to server: $dataToSend');

    socket.once('payment-response', (data) {
      print('Received from server: $data');
      _showResponseDialog(data.toString());
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResponseDialog(String response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Server Response'),
          content: Text(response),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRedirectPopup(String redirectUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Authorization'),
          content: Text('Click the link below to authorize the payment:'),
          actions: <Widget>[
            TextButton(
              child: Text('Open Link'),
              onPressed: () async {
                if (await canLaunch(redirectUrl)) {
                  await launch(redirectUrl);
                } else {
                  throw 'Could not launch $redirectUrl';
                }
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
        backgroundColor: const Color.fromARGB(255, 20, 134, 81),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20.0,
                  spreadRadius: 10.0,
                  offset: Offset(5.0, 5.0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Address
                _buildInputField(
                    'Wallet Address', 'Enter Email', (value) => email = value),

                // Customer Name
                _buildInputField(
                    'Customer Name', 'Enter Name', (value) => name = value),

                // Affiliation Number
                _buildInputField(
                    'Affiliation Number',
                    'Enter Affiliation Number',
                    (value) => affiliationNumber = value),

                // Amount to Pay
                _buildInputField('Amount to Pay', 'Enter Amount',
                    (value) => amountToPay = value, TextInputType.number),

                // Payment Type
                _buildDropdownField(),

                SizedBox(height: 16.0),

                // Buttons: Cancel and Pay
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handlePayment,
                        child: Text('Pay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, Function(String) onChanged,
      [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        Container(
          margin: EdgeInsets.only(top: 8.0, bottom: 16.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.white),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Type',
          style: TextStyle(color: Colors.white),
        ),
        DropdownButton<String>(
          value: paymentType,
          dropdownColor: Colors.grey[850],
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          isExpanded: true,
          style: TextStyle(color: Colors.white),
          onChanged: (String? newValue) {
            setState(() {
              paymentType = newValue!;
            });
          },
          items: <String>['Card', 'Google Pay', 'Bank']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

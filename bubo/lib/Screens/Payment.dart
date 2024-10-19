import 'dart:convert';

import 'package:bubo/Screens/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  void _handlePayment() async {
    //this will call openpayment apis
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
                Text(
                  'Email Address',
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
                      hintText: 'Enter Email',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                ),

                // Customer Name
                Text(
                  'Customer Name',
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
                      hintText: 'Enter Name',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                ),

                // Affiliation Number
                Text(
                  'Affiliation Number',
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
                      hintText: 'Enter Affiliation Number',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        affiliationNumber = value;
                      });
                    },
                  ),
                ),

                // Amount to Pay
                Text(
                  'Amount to Pay',
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
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        amountToPay = value;
                      });
                    },
                  ),
                ),

                // Payment Type
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

                SizedBox(height: 16.0), // Add spacing before the buttons

                // Buttons: Cancel and Pay
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                              context); // Navigate back to the home page
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
}

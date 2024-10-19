import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:bubo/Screens/budget_model.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class CreateGoalScreen extends StatefulWidget {
  final List<Budget> budgets;
  double amount;

  CreateGoalScreen({required this.budgets, required this.amount});

  @override
  _CreateGoalScreenState createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedEmoji = '🎯'; // Default emoji

  Future<void> createBudget(Budget budget) async {
    final url = Uri.parse('http://localhost:8020/budgets/');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(budget.toJson()),
      );

      if (response.statusCode == 200) {
        print('Budget created successfully');
      } else {
        print('Failed to create budget. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error creating budget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 43, 41, 41), // Set background color to black
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color.fromARGB(
            255, 43, 41, 41), // Set AppBar background color to black
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Categorize", style: TextStyle(color: Colors.white)),
                  TextField(
                    controller: _goalNameController,
                    decoration: InputDecoration(
                      hintText: 'Name of your expense',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: UnderlineInputBorder(),
                      prefixText: 'R',
                      prefixStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () {
                // Show emoji picker
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        setState(() {
                          _selectedEmoji = emoji.emoji;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pick an emoji',
                        style: TextStyle(color: Colors.white)),
                    Text(_selectedEmoji,
                        style: TextStyle(fontSize: 24, color: Colors.white)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text('Create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_goalNameController.text.isNotEmpty &&
                      _amountController.text.isNotEmpty) {
                    double enteredAmount = double.parse(_amountController.text);

                    if (enteredAmount <= widget.amount) {
                      Budget newBudget = Budget(
                        emoji: _selectedEmoji,
                        category: _goalNameController.text,
                        amount: enteredAmount,
                      );
                      await createBudget(newBudget);
                      widget.budgets.add(newBudget);

                      // Pass the reduced amount back to HomeScreen
                      Navigator.pop(context, widget.amount - enteredAmount);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Entered amount exceeds available balance')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please fill all required fields')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

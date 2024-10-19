// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:bubo/Screens/Payment.dart';
import 'package:bubo/Screens/create_Budget.dart';
import 'package:bubo/Screens/budget_model.dart';
import 'package:bubo/Screens/offer_loan_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  double _balance = 1000.00; // Initial balance
  List<Budget> _budgets = [];
  bool _isLoading = true;
  ScrollController _scrollController = ScrollController();
  double _profileIconPosition = 17.0;

  @override
  bool get wantKeepAlive => true; // Ensures the state is kept alive

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
    _scrollController.addListener(_updateProfileIconPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProfileIconPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateProfileIconPosition() {
    setState(() {
      _profileIconPosition = 17.0 + _scrollController.offset;
    });
  }

  Future<void> _fetchBudgets() async {
    //fetch the budgets fro the tigerbeetle
  }

  void _updateBudget(Budget updatedBudget) {
    setState(() {
      int index =
          _budgets.indexWhere((b) => b.category == updatedBudget.category);
      if (index != -1) {
        _budgets[index] = updatedBudget;
      }
    });
    // Optionally, you can update the backend here
    // _updateBudgetOnBackend(updatedBudget);
  }

  Future<void> _deleteBudget(String category) async {
    final response =
        await http.delete(Uri.parse('http://localhost:8020/budgets/$category'));

    if (response.statusCode == 200) {
      _fetchBudgets();
    } else {
      throw Exception('Failed to delete budget');
    }
  }

  Widget _buildServiceItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableTransactionItem(Budget budget) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentMethodsPage(
              budget: budget,
              onBudgetUpdated: _updateBudget,
            ),
          ),
        );
      },
      onLongPress: () {
        _deleteBudget(budget.category);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(budget.category, style: TextStyle(fontSize: 16)),
              ],
            ),
            Text(
              'R${budget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 55, 73, 56),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 128, 67, 226),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 128, 67, 226),
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
                children: [
                  SizedBox(
                      height: 100), // Increased top padding for profile icon
                  // Available Balance Container
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 227, 238, 227),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 128, 67, 226),
                            blurRadius: 20.0,
                            spreadRadius: 5.0,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Available Balance: ',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 15)),
                          Text(
                            'R${_balance.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Services Text (Outside Container)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Services Component
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 124, 180, 124),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 128, 67, 226),
                            blurRadius: 20.0,
                            spreadRadius: 5.0,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildServiceItem(
                              Icons.compare_arrows,
                              'Lend money',
                              const Color.fromARGB(255, 94, 117, 219),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OfferLoanScreen()),
                                );
                              },
                            ),
                            _buildServiceItem(
                              Icons.add,
                              'Deposit',
                              Colors.pink,
                              () {
                                // Handle deposit tap
                                print('Deposit tapped');
                                // Add your logic here, e.g., show deposit dialog
                              },
                            ),
                            _buildServiceItem(
                              Icons.payment,
                              'Make Payment',
                              Colors.purple,
                              () {
                                // Handle make payment tap
                                print('Make Payment tapped');
                                // Add your logic here, e.g., navigate to payment screen
                              },
                            ),
                            _buildServiceItem(
                              Icons.lightbulb_outline,
                              'Pay Bill',
                              Colors.orange,
                              () {
                                // Handle pay bill tap
                                print('Pay Bill tapped');
                                // Add your logic here, e.g., show bill payment options
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Budget Text (Outside Container)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Budget',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Budget Component
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 227, 238, 227),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(66, 248, 253, 252),
                            blurRadius: 20.0,
                            spreadRadius: 5.0,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            ..._budgets
                                .map((budget) =>
                                    _buildClickableTransactionItem(budget))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateGoalScreen(
                              budgets: _budgets,
                              amount: _balance,
                            ),
                          ),
                        );

                        if (result != null && result is double) {
                          _updateBalance(result);
                        }
                      },
                      child: Text('Add More Categories'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Profile Icon Sticky at the Top
          Positioned(
            top: _profileIconPosition,
            left: 17,
            child: GestureDetector(
              onTap: () {
                // Handle profile icon tap
                // You can show a modal bottom sheet or navigate to a profile page
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text('Profile'),
                            onTap: () {
                              // Navigate to ProfileScreen
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text('Settings'),
                            onTap: () {
                              // Navigate to SettingsScreen
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Sign Out'),
                            onTap: () {
                              // Handle sign out action
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateBalance(double newBalance) {
    setState(() {
      _balance = newBalance;
    });
  }
}

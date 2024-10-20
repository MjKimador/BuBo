import 'package:flutter/material.dart';
import 'dart:async';

class LoanOffer {
  final String amount;
  final String interest;
  final String repayment;
  String status; // Added status field to track loan offer status

  LoanOffer({
    required this.amount,
    required this.interest,
    required this.repayment,
    this.status = 'Available', // Default status is "Available"
  });
}

class LoanOffersScreen extends StatefulWidget {
  @override
  _LoanOffersScreenState createState() => _LoanOffersScreenState();
}

class _LoanOffersScreenState extends State<LoanOffersScreen> {
  List<LoanOffer> loanOffers = [
    LoanOffer(amount: 'R50', interest: '5%', repayment: 'Monthly repayments'),
    LoanOffer(
        amount: 'R100', interest: '4.5%', repayment: 'Quarterly repayments'),
    LoanOffer(amount: 'R120', interest: '30%', repayment: 'Weekly repayments'),
  ];

  TextEditingController walletController = TextEditingController();
  TextEditingController searchController =
      TextEditingController(); // Controller for search bar

  void _removeLoanOffer(int index) {
    setState(() {
      loanOffers.removeAt(index);
    });
  }

  Future<void> _showLoadingDialog() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 16),
              Text(
                'Processing your request...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );

    // Simulate loading for 2 seconds
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
    }
  }

  Future<void> _showWalletAddressDialog(int index) async {
    walletController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            'Enter Wallet Address',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: walletController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your wallet address',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit', style: TextStyle(color: Colors.green)),
              onPressed: () {
                if (walletController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  print(
                      'Processing loan with wallet address: ${walletController.text}');

                  // Mark the loan offer as "Pending"
                  setState(() {
                    loanOffers[index].status = 'Pending';
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _acceptLoanOffer(int index) async {
    // Show loading first
    await _showLoadingDialog();

    // Show wallet address input after loading
    await _showWalletAddressDialog(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Loan Offers'),
        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        color: Colors.grey[850],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController, // Attach controller
                decoration: InputDecoration(
                  hintText: 'Enter desired loan amount',
                  hintStyle:
                      TextStyle(color: Colors.white), // Make text visible
                  suffixIcon: Icon(Icons.search,
                      color: Colors.white), // Make icon white
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                    color: Colors.white), // Ensure input text is white
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: loanOffers.length,
                itemBuilder: (context, index) {
                  return _buildLoanOfferCard(
                    loanOffer: loanOffers[index],
                    onReject: () => _removeLoanOffer(index),
                    onAccept: () => _acceptLoanOffer(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanOfferCard({
    required LoanOffer loanOffer,
    required VoidCallback onReject,
    required VoidCallback onAccept,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loanOffer.amount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${loanOffer.interest} Interest',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              loanOffer.repayment,
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 8),
            Text(
              loanOffer.status, // Display the status of the loan
              style: TextStyle(
                color: loanOffer.status == 'Pending'
                    ? Colors.orange
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReject,
                    child: Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

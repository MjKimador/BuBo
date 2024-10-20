import 'package:flutter/material.dart';

class LoanOffer {
  final String amount;
  final String interest;
  final String repayment;

  LoanOffer(
      {required this.amount, required this.interest, required this.repayment});
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
    LoanOffer(amount: 'R120', interest: '30%', repayment: 'weekly'),
    // Add more initial loan offers here
  ];

  void _removeLoanOffer(int index) {
    setState(() {
      loanOffers.removeAt(index);
    });
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
                decoration: InputDecoration(
                  hintText: 'Enter desired loan amount',
                  suffixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: loanOffers.length,
                itemBuilder: (context, index) {
                  return _buildLoanOfferCard(
                    loanOffer: loanOffers[index],
                    onReject: () => _removeLoanOffer(index),
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
                  '% ${loanOffer.interest} Interest',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              loanOffer.repayment,
              style: TextStyle(color: Colors.grey[400]),
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
                    onPressed: () {
                      // Implement accept functionality
                    },
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

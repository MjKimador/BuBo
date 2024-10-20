import 'package:flutter/material.dart';

class OfferLoanScreen extends StatefulWidget {
  @override
  _OfferLoanScreenState createState() => _OfferLoanScreenState();
}

class _OfferLoanScreenState extends State<OfferLoanScreen> {
  String? _selectedRepaymentSchedule;
  final List<String> _repaymentSchedules = ['Weekly', 'Bi-weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Offer a Loan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 61, 59, 59),
      ),
      backgroundColor: const Color.fromARGB(255, 61, 59, 59),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField('Loan Amount', 'Enter loan amount'),
            SizedBox(height: 16),
            _buildInputField('Interest Rate (%)', 'Enter interest rate'),
            SizedBox(height: 16),
            _buildDropdown(),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file, color: Colors.white),
              label: Text('Upload Loan Offer',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Handle loan offer upload
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: const Color.fromARGB(216, 252, 245, 245)),
            filled: true,
            fillColor: Color.fromARGB(255, 243, 245, 247),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Repayment Schedule', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 61, 59, 59),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          dropdownColor: const Color.fromARGB(255, 61, 59, 59),
          style: TextStyle(color: Colors.white),
          hint: Text('Select repayment schedule',
              style: TextStyle(color: Colors.white30)),
          value: _selectedRepaymentSchedule,
          onChanged: (String? newValue) {
            setState(() {
              _selectedRepaymentSchedule = newValue;
            });
          },
          items:
              _repaymentSchedules.map<DropdownMenuItem<String>>((String value) {
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

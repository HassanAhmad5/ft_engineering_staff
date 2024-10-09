import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ft_engineering_staff/Components/reuseable_widgets.dart';

class AddExpenseScreen extends StatefulWidget {
  final String orderId;

  const AddExpenseScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to add expense to the order's expense array
  Future<void> addExpense() async {
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(_amountController.text);
      String details = _detailsController.text;

      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId)
          .update({
        'expense': FieldValue.arrayUnion([{
          'amount': amount,
          'details': details,
          'date': DateTime.now(),
        }]),
      });

      // Pop the screen after adding the expense
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade200,
        title: const Text(
          "Ft Engineering",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Expense Amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expense amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the details of the expense';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ReuseableButton(text: 'Add Expense', onPressed: addExpense)
            ],
          ),
        ),
      ),
    );
  }
}

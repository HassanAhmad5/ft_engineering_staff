import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ft_engineering_staff/Components/reuseable_widgets.dart';

class EditExpenseScreen extends StatefulWidget {
  final String orderId;
  final int expenseIndex;
  final Map<String, dynamic> expense;

  const EditExpenseScreen({
    Key? key,
    required this.orderId,
    required this.expenseIndex,
    required this.expense,
  }) : super(key: key);

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _detailsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense['amount'].toString());
    _detailsController =
        TextEditingController(text: widget.expense['details']);
  }

  // Function to update the expense in Firestore
  Future<void> updateExpense() async {
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(_amountController.text);
      String details = _detailsController.text;

      DocumentReference orderRef =
      FirebaseFirestore.instance.collection('orders').doc(widget.orderId);

      await orderRef.update({
        'expense.${widget.expenseIndex}': {
          'amount': amount,
          'details': details,
          'date': DateTime.now(),
        }
      });

      Navigator.pop(context);
    }
  }

  // Function to delete the expense from Firestore
  Future<void> deleteExpense() async {
    DocumentReference orderRef =
    FirebaseFirestore.instance.collection('orders').doc(widget.orderId);

    await orderRef.update({
      'expense': FieldValue.arrayRemove([widget.expense]),
    });

    Navigator.pop(context);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteExpense,
          ),
        ],
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
                  border: OutlineInputBorder(),
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
              ReuseableButton(text: 'Update Expense', onPressed: updateExpense)
            ],
          ),
        ),
      ),
    );
  }
}

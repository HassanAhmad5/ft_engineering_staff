import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  final String orderId;

  const ExpenseListScreen({Key? key, required this.orderId}) : super(key: key);

  // Function to stream the order data for real-time updates
  Stream<DocumentSnapshot> getOrderStream() {
    return FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots();
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: getOrderStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No expenses available'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>?;
          if (orderData == null) {
            return const Center(child: Text('No expenses available'));
          }

          List<dynamic> expenses = orderData['expense'] ?? [];

          // Calculate total expense
          double totalExpense = expenses.fold(
              0, (sum, item) => sum + (item['amount'] ?? 0));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Expense: ${totalExpense.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      elevation: 3,
                      child: ListTile(
                        title: Text('Amount: ${expense['amount'].toStringAsFixed(0)}'),
                        subtitle: Text('Details: ${expense['details']}'),
                        onTap: () {
                          // Navigate to EditExpenseScreen to edit/delete the expense
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditExpenseScreen(
                                orderId: orderId,
                                expenseIndex: index,
                                expense: expense,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddExpenseScreen when FAB is clicked
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(orderId: orderId),
            ),
          );
        },
        backgroundColor: Colors.yellow.shade200,
        child: const Icon(Icons.add),
      ),
    );
  }
}

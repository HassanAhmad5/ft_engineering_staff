import 'package:flutter/material.dart';

class CompletedOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final double totalPrice;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> expense;  // Added expense list
  final DateTime orderDate;
  final String clientId;
  CompletedOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.products,
    required this.expense,
    required this.orderDate,
    required this.clientId,
  });

  @override
  State<CompletedOrderDetailScreen> createState() =>
      _CompletedOrderDetailScreenState();
}

class _CompletedOrderDetailScreenState
    extends State<CompletedOrderDetailScreen> {
  String? selectedStaffId; // Hold the selected staff member's ID
  Map<String, dynamic>? clientData; // Store client data
  List<Map<String, dynamic>> staffMembers = []; // Store staff members

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data on initialization
  }

  // Dummy method to simulate client data fetch
  Future<void> fetchData() async {
    // You can add the logic for fetching client details here
    setState(() {
      clientData = {
        'name': 'John Doe',
        'phone': '1234567890',
        'shop_name': 'Best Shop',
        'shop_address': '123 Main St',
        'area_name': 'Downtown',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

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
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.02,
          horizontal: screenSize.width * 0.05,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: Order Details
              Text(
                'Order Details:',
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${widget.orderId}',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Order Date: ${widget.orderDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: screenSize.width * 0.04),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Products:',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.products.length,
                        itemBuilder: (context, index) {
                          final product = widget.products[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: screenSize.height * 0.1,
                                    width: screenSize.width * 0.2,
                                    child: Image.network(
                                      product['imageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Quantity: ${product['quantity']}',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.035,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Price: ${product['price'].toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: screenSize.width * 0.035,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Total Price: ${widget.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 2: Client Details
              if (clientData != null) ...[
                Text(
                  'Client Details:',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client Name: ${clientData!['name']}',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Phone: ${clientData!['phone']}',
                            style: TextStyle(fontSize: screenSize.width * 0.04),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Shop Name: ${clientData!['shop_name']}',
                            style: TextStyle(fontSize: screenSize.width * 0.04),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Shop Address: ${clientData!['shop_address']}',
                            style: TextStyle(fontSize: screenSize.width * 0.04),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Area Name: ${clientData!['area_name']}',
                            style: TextStyle(fontSize: screenSize.width * 0.04),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (clientData == null) ...[
                const Center(child: CircularProgressIndicator()),
              ],

              const SizedBox(height: 20),

              // SECTION 3: Expense Details
              Text(
                'Expense Details:',
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.expense.length,
                    itemBuilder: (context, index) {
                      final expense = widget.expense[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expense['details'],
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${expense['amount'].toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: screenSize.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

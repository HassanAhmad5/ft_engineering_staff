import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ft_engineering_staff/Components/reuseable_widgets.dart';
import 'package:ft_engineering_staff/Home/Order_Management/Expense/expense_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PendingOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final double totalPrice;
  final List<Map<String, dynamic>> products;
  final DateTime orderDate;
  final String clientId; // Assume clientId is passed in the constructor

  const PendingOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.products,
    required this.orderDate,
    required this.clientId, // Add clientId here
  });

  @override
  State<PendingOrderDetailScreen> createState() => _PendingOrderDetailScreenState();
}

class _PendingOrderDetailScreenState extends State<PendingOrderDetailScreen> {
  String? selectedStaffId; // Hold the selected staff member's ID
  Map<String, dynamic>? clientData; // Store client data
  List<Map<String, dynamic>> staffMembers = []; // Store staff members

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data on initialization
  }

  Future<void> fetchData() async {
    // Fetch client details
    var clientDoc = await FirebaseFirestore.instance.collection('users').doc(widget.clientId).get();
    if (clientDoc.exists) {
      clientData = clientDoc.data() as Map<String, dynamic>;
    }

    // Fetch staff members based on the client's area
    if (clientData != null) {
      String areaName = clientData!['area_name'];
      QuerySnapshot staffSnapshot = await FirebaseFirestore.instance
          .collection('staff')
          .where('area_names', arrayContains: areaName) // Check if areaNames contains the areaName
          .get();

      staffMembers = staffSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    else {
      staffMembers = [];
    }

    // Refresh the UI
    setState(() {});
  }

  Future<void> openGoogleMaps(double destinationLat, double destinationLng) async {
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving');

    if (await launchUrl(
      googleMapsUri,
      mode: LaunchMode.externalApplication,  // Open in an external app (Google Maps)
    )) {
      // Successfully opened Google Maps
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  Future<void> completeOrder(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'status': 'completed',
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order Completed Successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete order')),
      );
    }
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Client Details:',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          openGoogleMaps(clientData!['shop_location']['latitude'], clientData!['shop_location']['longitude']);
                        },
                          child: const Icon(Icons.pin_drop_outlined, size: 26,)
                      ),
                    )
                  ],
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReuseableButton(text: 'Complete Order', onPressed: () async {
                      // Show confirmation dialog before canceling the order
                      bool confirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Complete Order'),
                          content: const Text('Are you sure you want to complete this order?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No', style: TextStyle(color: Colors.deepOrange),),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Yes', style: TextStyle(color: Colors.green),),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        // If confirmed, proceed to cancel the order
                        await completeOrder(context);
                      }
                    },),
                    ReuseableButton(text: 'Add Expense', onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseListScreen(orderId: widget.orderId)));
                    })
                  ],
                )
              ] else if (clientData == null) ...[
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

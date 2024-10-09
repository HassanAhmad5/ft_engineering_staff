import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Order_Management/order_detail_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedStaffId; // Hold the selected staff member's ID
  List<Map<String, dynamic>>? orderData;
  Map<String, dynamic>? clientData; // Store client data

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> getOrdersByStaff() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('assigned_staffId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'in progress')
        .snapshots();
  }

  Future<Map<String, dynamic>?> getClientData(String clientId) async {
    DocumentSnapshot clientSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(clientId).get();
    if (clientSnapshot.exists) {
      return clientSnapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.01,
          horizontal: screenSize.width * 0.02,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 0.05 * MediaQuery.of(context).size.width),
                  child: const Text(
                    "Assigned Orders",
                    style: TextStyle(fontSize: 23),
                  ),
                ),
              ),
              buildPendingOrderList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPendingOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: getOrdersByStaff(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No orders available'),
          );
        }

        var orders = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true, // Add shrinkWrap to avoid ListView issues inside Column
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var orderData = orders[index].data() as Map<String, dynamic>;
            String orderId = orders[index].id;
            String clientId = orderData['clientId']; // Get clientId from the order
            double totalPrice = orderData['totalPrice'];
            List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(orderData['products']);
            DateTime orderDate = (orderData['orderDate'] as Timestamp).toDate();

            return FutureBuilder<Map<String, dynamic>?>(
              future: getClientData(clientId),
              builder: (context, clientSnapshot) {
                if (clientSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                if (!clientSnapshot.hasData) {
                  return const Center(child: Text('Client details not found'));
                }

                var clientData = clientSnapshot.data!;
                String clientName = clientData['name'];
                String shopName = clientData['shop_name'];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text('Order ID: $orderId'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: $clientName'),
                        Text('Shop: $shopName'),
                        Text('Products: ${products.length}'),
                        Text('Total Price: ${totalPrice.toStringAsFixed(0)}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PendingOrderDetailScreen(
                            orderId: orderId,
                            totalPrice: totalPrice,
                            products: products,
                            orderDate: orderDate,
                            clientId: clientId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

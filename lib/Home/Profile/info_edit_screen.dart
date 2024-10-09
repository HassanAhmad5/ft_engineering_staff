import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Model/postal_area_model.dart';
import '../../Utils/utilities.dart';

class InfoEditScreen extends StatefulWidget {
  const InfoEditScreen({super.key});

  @override
  State<InfoEditScreen> createState() => _InfoEditScreenState();
}

class _InfoEditScreenState extends State<InfoEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isLoading = false;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('staff').doc(currentUser.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';


        setState(() {}); // Refresh the UI after loading data
      }
    }
  }



  Future<void> _saveUserDataToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('staff').doc(currentUser.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        });

        Utilities().successMsg('Profile Updated Successfully');
        Navigator.pop(context);
      } catch (e) {
        Utilities().errorMsg('Failed to update profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade200,
        title: const Text(
          "Ft Engineering",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.jpeg',
                width: 150,
                height: 150,
                fit: BoxFit.fill,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:
                        const InputDecoration(labelText: 'Enter Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Phone Number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width),
                        child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                await _saveUserDataToFirestore();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow.shade200,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                            child: isLoading
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    color: Colors.yellow.shade200,
                                    height: 20,
                                    width: 20,
                                    child: const CircularProgressIndicator(color: Colors.black)),
                                const SizedBox(width: 5),
                                const Text('Loading',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Update Profile",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            )),
                      ),

                    ],
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


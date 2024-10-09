import 'dart:convert';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ft_engineering_staff/Home/AppBar_NavBar/appbar_navbar.dart';
import 'package:http/http.dart' as http;

import '../Home/home_screen.dart';
import '../Model/postal_area_model.dart';
import '../Utils/utilities.dart';

class SignupDetailsScreen extends StatefulWidget {
  const SignupDetailsScreen({super.key});

  @override
  State<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends State<SignupDetailsScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _dropdownSearchFieldController = TextEditingController();

  bool isAreasAvailable = true;
  bool isLoading = false;

  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  List<PostalAreaModel> areas = [];
  List<String> _selectedAreas = [];

  Future<List<PostalAreaModel>> getAreas() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/HassanAhmad5/Islamabad_Rawalpindi_Postal_Areas_API/main/Islamabad_Rawalpindi_Postal_Areas.json'));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      areas.clear(); // Clear previous data if any
      for (var item in data) {
        areas.add(PostalAreaModel.fromJson(item));
      }
      setState(() {
        isAreasAvailable = false;
      });
      return areas;
    } else {
      print("Error in API");
      return areas;
    }
  }

  // Suggestions based on user query
  List<String> getSuggestions(String query) {
    List<String> matches = [];

    // Ensure data is not empty
    if (areas.isEmpty) {
      print("No areas available to search");
      return matches;
    }

    // Filter areas based on query
    for (var area in areas) {
      if (area.areaName != null &&
          area.areaName!.toLowerCase().contains(query.toLowerCase())) {
        matches.add(area.areaName!);
      }
    }
    return matches;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _saveUserDataToFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('staff').doc(currentUser.uid).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'area_names': _selectedAreas, // Save the list of selected areas
          'email': currentUser.email, // If email was used for signup
          'uid': currentUser.uid,
        });

        Utilities().successMsg('Profile Created Successfully');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppbarNavbar()));
      } catch (e) {
        Utilities().errorMsg('Failed to create profile: $e');
      }
    } else {
      Utilities().errorMsg('No user found');
    }
  }

  @override
  void initState() {
    getAreas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isAreasAvailable
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.jpeg',
            width: 150,
            height: 150,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              )),
        ],
      )
          : Center(
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
                      const SizedBox(height: 16),
                      // Multi-Selection Field for Areas
                      DropDownSearchFormField(
                        textFieldConfiguration: TextFieldConfiguration(
                          decoration: const InputDecoration(
                            labelText: 'Select Area Name For Delivery',
                          ),
                          controller: _dropdownSearchFieldController,
                        ),
                        suggestionsCallback: (pattern) {
                          return getSuggestions(pattern);
                        },
                        itemBuilder: (context, String suggestion) {
                          return ListTile(
                            tileColor: Colors.white,
                            title: Text(suggestion),
                            trailing: _selectedAreas.contains(suggestion)
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                          );
                        },
                        transitionBuilder: (context, suggestionsBox, controller) {
                          return suggestionsBox;
                        },
                        onSuggestionSelected: (String suggestion) {
                          setState(() {
                            if (_selectedAreas.contains(suggestion)) {
                              _selectedAreas.remove(suggestion); // Remove if already selected
                            } else {
                              _selectedAreas.add(suggestion); // Add if not selected
                            }
                          });
                        },
                        suggestionsBoxController: suggestionBoxController,
                        validator: (value) => _selectedAreas.isEmpty
                            ? 'Please select at least one area'
                            : null,
                        displayAllSuggestionWhenTap: true,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SelectedAreasWidget(
                            selectedAreas: _selectedAreas,
                            onDeselect: (area) {
                              setState(() {
                                _selectedAreas.remove(area);
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            0.1 * MediaQuery.of(context).size.width),
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
                                    borderRadius:
                                    BorderRadius.circular(15))),
                            child: isLoading
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Container(
                                    color: Colors.yellow.shade200,
                                    height: 20,
                                    width: 20,
                                    child: const CircularProgressIndicator(
                                      color: Colors.black,
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
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
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text("Create Profile",
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

class SelectedAreasWidget extends StatelessWidget {
  final List<String> selectedAreas;
  final Function(String) onDeselect;

  const SelectedAreasWidget({
    Key? key,
    required this.selectedAreas,
    required this.onDeselect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: selectedAreas.map((area) {
        return Chip(
          backgroundColor: Colors.yellow.shade50,
          label: Text(area),
          onDeleted: () => onDeselect(area), // Call the callback to handle deselecting
        );
      }).toList(),
    );
  }
}


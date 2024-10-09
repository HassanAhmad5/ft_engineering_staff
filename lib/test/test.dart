import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigateToClientScreen extends StatelessWidget {
  final double clientLat;
  final double clientLng;

  const NavigateToClientScreen({
    super.key,
    required this.clientLat,
    required this.clientLng,
  });


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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Location'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            openGoogleMaps(clientLat, clientLng);
          },
          child: const Text('Navigate to Client'),
        ),
      ),
    );
  }
}


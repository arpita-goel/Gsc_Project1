// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LocationPage extends StatefulWidget {
//   const LocationPage({super.key});

//   @override
//   State<LocationPage> createState() => _LocationPageState();
// }

// class _LocationPageState extends State<LocationPage> {
//   String _status = 'Fetching location...';

//   @override
//   void initState() {
//     super.initState();
//     _openMapsWithCurrentLocation();
//   }

 
// Future<void> _openMapsWithCurrentLocation() async {
//   bool serviceEnabled;
//   LocationPermission permission;

//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     setState(() {
//       _status = 'Location services are disabled.';
//     });
//     return;
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       setState(() {
//         _status = 'Location permissions are denied';
//       });
//       return;
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     setState(() {
//       _status = 'Location permissions are permanently denied.';
//     });
//     return;
//   }

//   Position position = await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );

//   final latitude = position.latitude;
//   final longitude = position.longitude;

// final Uri geoUri = Uri.parse('geo:$latitude,$longitude?q=nearby+places');

// if (await canLaunchUrl(geoUri)) {
//  await launchUrl(geoUri, mode: LaunchMode.externalApplication);
// } else {
//   setState(() {
//     _status = 'Could not open Google Maps.';
//   });
// }

// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Location'),
//       ),
//       body: Center(
//         child: Text(
//           _status,
//           style: const TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }

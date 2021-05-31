import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Markers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  Completer<GoogleMapController> _controller = Completer();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};



  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() {
    _firebase.collection('places').get().then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (int i = 0; i < snapshot.docs.length; i++) {
          createMarker(snapshot.docs[i]['coordinates'] ,snapshot.docs[i].data(),
              snapshot.docs[i].id);
        }
      }
    });
  }

  void createMarker(GeoPoint coordinates,details, documentID) {
    final MarkerId markerId = MarkerId(documentID);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(coordinates.latitude, coordinates.longitude),
      infoWindow: InfoWindow(title: details['name'], snippet: details['info']),
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              39.91977847612015,
              33.23370862967007,
            ),
            zoom: 5,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: Set<Marker>.of(markers.values),
        ),
    );
  }
}

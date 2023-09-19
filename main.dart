import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:html' as html;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VEHICLE - GPS LOCATOR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Φορτηγάκι'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String latitude = "";
  String longitude = "";
  String time = "";

  String new_latitude = "";
  String new_longitude = "";
  String new_time = "";

  String doc_id = "";

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: _launchURL,
                child: const Text('Show map'),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                )),
            const SizedBox(height: 20),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("coordinates")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      'No Data...',
                    );
                  } else {
                    // longitude = snapshot.data?.docs[0]["long"];
                    // latitude = snapshot.data?.docs[0]["lat"];

                    return Column(
                      children: [
                        const Text(
                          'Latitude',
                        ),
                        Text(snapshot.data?.docs[0]["lat"],
                            style: DefaultTextStyle.of(context)
                                .style
                                .apply(fontSizeFactor: 1.0)),
                        const SizedBox(height: 10),
                        const Text(
                          'Longitude',
                        ),
                        Text(snapshot.data?.docs[0]["long"]),
                        const SizedBox(height: 10),
                        const Text(
                          'Date-Time',
                        ),
                        Text(snapshot.data?.docs[0]["time"],
                            style: DefaultTextStyle.of(context)
                                .style
                                .apply(fontSizeFactor: 1.5)),
                        const SizedBox(height: 10),
                      ],
                    );
                  }
                }

                //Text(snapshot.data?.docs[0]["lat"])
                //const SizedBox(height: 10),

                // const Text(
                //   'Longitude',
                // ),
                // Text(
                //   '$longitude',
                //   style: Theme.of(context).textTheme.headline4,
                // ),
                )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAlertDialog(context);
        },
        tooltip:
            '[Add current location] Προσθήκη τρέχουσας τοποθεσίας (internet & GPS απαραίτητα)',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Ακύρωση(Cancel)"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
        get_loc();
      },
    );
    // Navigator.of(context).pop();

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Ειδοποίηση(Alert)"),
      content: const Text(
          "Πρόκειται να στείλετε το στίγμα GPS της τοποθεσίας σας στην εφαρμογή."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  CollectionReference coordinates =
      FirebaseFirestore.instance.collection('coordinates');

  void get_loc() async {
    db_fetch_loc();
    final Location location = new Location();
    final _locationData = await location.getLocation();
    setState(() {
      new_latitude = _locationData.latitude.toString();
      new_longitude = _locationData.longitude.toString();
    });
    //print(new_latitude);
    //print("eee");
    coordinates
        .doc(doc_id)
        .update({
          'long': new_longitude,
          'lat': new_latitude,
          'time': DateTime.now().toString()
        })
        .then((value) => showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  // Retrieve the text the that user has entered by using the
                  // TextEditingController.
                  content: Text("Τα Στοιχεία ενημερώθηκαν"),
                );
              },
            ))
        //.then((value) => )
        .catchError((error) => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  // Retrieve the text the that user has entered by using the
                  // TextEditingController.
                  content: Text("Σφάλμα ενημέρωσης =  $error"),
                );
              },
            ));
  }

  // Future<void> db_update_coordinates() {}

  void _launchURL() async {
    //final lat = new_latitude;
    //final long = new_longitude;
    //final url = 'https://www.google.com/maps/@$lat,${long}19z';
    await FirebaseFirestore.instance
        .collection('coordinates')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        longitude = doc["long"];
        latitude = doc["lat"];
        time = doc["time"].toString();
        doc_id = doc.id;
      });
      //print(latitude);
    }).catchError((e) {
      //print(e);
    });
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    html.window.open(url, "_blank");
    // print(url);

    // final uri = Uri.parse(url);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  db_fetch_loc() async {
    await FirebaseFirestore.instance
        .collection('coordinates')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        longitude = doc["long"];
        latitude = doc["lat"];
        time = doc["time"].toString();
        doc_id = doc.id;
      });
      //print(latitude);
    }).catchError((e) {
      //print(e);
    });
  }
}

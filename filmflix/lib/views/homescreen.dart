import 'package:flutter/material.dart';

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoofdscherm van de Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Voeg hier logica toe om het spel te starten
                print('Spel starten');
              },
              child: Text('Start Spel'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Voeg hier logica toe voor opties
                print('Opties');
              },
              child: Text('Opties'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Voeg hier logica toe om af te sluiten
                print('Afsluiten');
              },
              child: Text('Afsluiten'),
            ),
          ],
        ),
      ),
    );
  }
}
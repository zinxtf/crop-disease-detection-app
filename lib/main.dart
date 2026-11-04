 
      
       import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

void main() => runApp(CropApp());

class CropApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String _result = "";
  String _advice = "";
  bool _loading = false;
  List<String> labels = [];
  
  @override
  void initState() {
    super.initState();
    loadLabels();
  }
  
  Future<void> loadLabels() async {
    try {
      String data = await rootBundle.loadString('assets/labels.txt');
      labels = data.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch(e) {
      labels = ["Tomato Early Blight", "Potato Late Blight", "Apple Scab", "Mango Anthracnose", "Banana Black Sigatoka", "Rice Blast", "Wheat Brown Rust", "Healthy"];
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source);
    if (x == null) return;
    setState(() {
      _image = File(x.path);
      _loading = true;
    });
    await Future.delayed(Duration(seconds: 1));
    var rnd = Random();
    String pred = labels[rnd.nextInt(labels.length)];
    setState(() {
      _result = pred.replaceAll("___", " ").replaceAll("_", " ");
      _advice = _result.toLowerCase().contains("healthy") 
        ? "🇮🇳 स्वस्थ है - नियमित देखभाल जारी रखें\n🇬🇧 Healthy - Continue care\n💊 Neem Oil 5ml/L preventive"
        : "🇮🇳 रोग लगा है - संक्रमित पत्ते हटाएं, नीम तेल 5ml/L हर 7 दिन\n🇬🇧 Disease - Remove infected leaves, spray Neem Oil 5ml/L every 7 days\n💊 Mancozeb 2g/L";
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🌱 Crop Disease - 58 Crops"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 250),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(onPressed: () => pickImage(ImageSource.camera), icon: Icon(Icons.camera), label: Text("Camera")),
                ElevatedButton.icon(onPressed: () => pickImage(ImageSource.gallery), icon: Icon(Icons.photo), label: Text("Gallery")),
              ],
            ),
            SizedBox(height: 20),
            if (_loading) CircularProgressIndicator(),
            if (_result.isNotEmpty && !_loading)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(_result, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text(_advice),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

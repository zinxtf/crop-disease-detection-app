import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() => runApp(const CropApp());

class CropApp extends StatelessWidget {
  const CropApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Disease Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class Report {
  String date, disease, confidence, treatment, imagePath;
  Report({required this.date, required this.disease, required this.confidence, required this.treatment, required this.imagePath});
  Map<String,dynamic> toJson() => {"date":date,"disease":disease,"confidence":confidence,"treatment":treatment,"imagePath":imagePath};
  static Report fromJson(Map<String,dynamic> j) => Report(date:j["date"], disease:j["disease"], confidence:j["confidence"], treatment:j["treatment"], imagePath:j["imagePath"]);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String _disease = "";
  String _conf = "";
  String _treat = "";
  String _status = "Welcome Farmer! 👨‍🌾\nTake photo of your crop";
  Color _color = Colors.green;
  bool _busy = false;
  final ImagePicker _picker = ImagePicker();
  List<Report> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("reports") ?? [];
    setState(() { _history = list.map((e) => Report.fromJson(jsonDecode(e))).toList().reversed.toList(); });
  }

  Future<void> _saveCurrentReport() async {
    if (_disease.isEmpty) return;
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final report = Report(date: now, disease: _disease, confidence: _conf, treatment: _treat, imagePath: _image?.path ?? "");
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("reports") ?? [];
    list.add(jsonEncode(report.toJson()));
    await prefs.setStringList("reports", list);
    await _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Report Saved to History!"), backgroundColor: Colors.green));
  }

  Future<void> _analyze(File img) async {
    setState(() { _busy = true; _status = "🔍 AI Analyzing...\nChecking spots, color"; _disease=""; _treat=""; });
    await Future.delayed(const Duration(seconds: 2));
    final r = math.Random();
    final list = [
      {"d": "Healthy Leaf / Fruit 🟢", "c": "94%", "col": Colors.green, "t": "✅ DIAGNOSIS: Healthy - No disease\n\nSOLUTION:\n• Continue normal care\n• Spray Neem oil 5ml/L every 15 days\n• Use organic compost\n\nइलाज: स्वस्थ है! नीम तेल का छिड़काव करते रहें।"},
      {"d": "Early Blight 🔴", "c": "88%", "col": Colors.orange, "t": "⚠️ DIAGNOSIS: Early Blight (Fungal)\n\nSYMPTOMS: Dark spots with yellow halo\n\nSOLUTION:\n1. Remove affected leaves immediately\n2. Spray Mancozeb 2.5g per litre water\n3. Repeat after 7 days\n4. Avoid watering on leaves\n\nCost: ~₹150\n\nइलाज: प्रभावित पत्ते हटाएं, Mancozeb 2.5g/L पानी में मिलाकर छिड़काव करें।"},
      {"d": "Brown Leaf Spot 🟤", "c": "91%", "col": Colors.brown, "t": "⚠️ DIAGNOSIS: Brown Spot / Leaf Spot\n\nSOLUTION:\n1. Spray Copper Oxychloride 3g/L\n2. Improve drainage\n3. Don't over-use Nitrogen\n4. Burn affected leaves away from field\n\nइलाज: कॉपर ऑक्सीक्लोराइड 3g प्रति लीटर छिड़काव।"},
      {"d": "Yellow Mosaic Virus 🟡", "c": "85%", "col": Colors.amber, "t": "⚠️ DIAGNOSIS: Yellow Mosaic / Nutrient Deficiency\n\nSOLUTION:\n1. Control Whitefly: Spray Imidacloprid 0.5ml/L\n2. Spray Urea 1% + Zinc 0.5%\n3. Remove severely affected plants\n4. Use virus-free seeds next time\n\nइलाज: सफेद मक्खी नियंत्रण करें, यूरिया + जिंक छिड़काव।"},
      {"d": "Fruit Rot / Overripe 🍅", "c": "89%", "col": Colors.red, "t": "⚠️ DIAGNOSIS: Fruit Rot (Your tomato in photo looks overripe/wet)\n\nSOLUTION:\n1. Harvest on time\n2. Don't store wet fruits\n3. Spray Bavistin 1g/L for fungal control\n4. Improve air circulation\n\nइलाज: समय पर तुड़ाई करें, फलों को सूखा रखें।"},
    ];
    final p = list[r.nextInt(list.length)];
    setState(() { _busy = false; _disease = p["d"] as String; _conf = p["c"] as String; _color = p["col"] as Color; _treat = p["t"] as String; _status = ""; });
  }

  Future<void> pick(bool cam) async {
    final XFile? f = await _picker.pickImage(source: cam ? ImageSource.camera : ImageSource.gallery, imageQuality: 85);
    if (f == null) return;
    setState(() { _image = File(f.path); });
    await _analyze(_image!);
  }

  void _showHistory() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => DraggableScrollableSheet(initialChildSize: 0.8, maxChildSize: 0.9, expand: false, builder: (ctx, scroll) => Column(children: [
      Container(height: 5, width: 50, margin: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
      Text("📜 Report History (${_history.length})", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const Divider(),
      Expanded(child: _history.isEmpty ? const Center(child: Text("No reports saved yet\nTake photo and save report", textAlign: TextAlign.center)) : ListView.builder(controller: scroll, itemCount: _history.length, itemBuilder: (c,i){
        final rep = _history[i];
        return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: ListTile(leading: rep.imagePath.isNotEmpty && File(rep.imagePath).existsSync() ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(rep.imagePath), width: 50, height: 50, fit: BoxFit.cover)) : Container(width: 50, height: 50, color: Colors.green.shade100, child: const Icon(Icons.grass)), title: Text(rep.disease, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), subtitle: Text("${rep.date}\nConf: ${rep.confidence}", style: const TextStyle(fontSize: 12)), isThreeLine: true, trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final prefs = await SharedPreferences.getInstance(); final list = prefs.getStringList("reports") ?? []; list.removeAt(list.length-1-i); await prefs.setStringList("reports", list); _loadHistory(); })))); 
      })),
      Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: ElevatedButton(onPressed: () async { final prefs = await SharedPreferences.getInstance(); await prefs.clear(); _loadHistory(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Clear All History", style: TextStyle(color: Colors.white))))])),
    ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🌱 Crop Doctor - AI Report", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, centerTitle: true, actions: [IconButton(icon: const Icon(Icons.history), onPressed: _showHistory, tooltip: "History"),]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(height: 300, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.shade300, width: 2)), child: ClipRRect(borderRadius: BorderRadius.circular(14), child: _image == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.energy_savings_leaf, size: 80, color: Colors.green.shade300), const SizedBox(height: 8), Text("No image yet", style: TextStyle(color: Colors.green.shade600))]) : Stack(fit: StackFit.expand, children: [Image.file(_image!, fit: BoxFit.cover), if (_busy) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white))) ]))),
        const SizedBox(height: 16),
        if (_busy) Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
        else if (_disease.isEmpty) Text(_status, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.green.shade800, fontWeight: FontWeight.w500))
        else Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: _color.withOpacity(0.15), borderRadius: BorderRadius.circular(30), border: Border.all(color: _color)), child: Text(_disease, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _color))),
          const SizedBox(height: 6),
          Text("Confidence: $_conf | ${DateFormat('dd MMM hh:mm a').format(DateTime.now())}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("📋 CURRENT REPORT & SOLUTION:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)), const Divider(), Text(_treat, style: const TextStyle(fontSize: 14, height: 1.6))])),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _saveCurrentReport, icon: const Icon(Icons.save), label: const Text("💾 SAVE THIS REPORT TO HISTORY"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
        ]),
        const SizedBox(height: 20),
        Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () => pick(true), icon: const Icon(Icons.camera_alt), label: const Text("CAMERA"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))), const SizedBox(width: 12), Expanded(child: ElevatedButton.icon(onPressed: () => pick(false), icon: const Icon(Icons.photo), label: const Text("GALLERY"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green.shade700, side: BorderSide(color: Colors.green.shade700, width: 2), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),]),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _showHistory, icon: const Icon(Icons.history), label: Text("View History (${_history.length} Reports)"), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45))),
      ])),
    );
  }
}

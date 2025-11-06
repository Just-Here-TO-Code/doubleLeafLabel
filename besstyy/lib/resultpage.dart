import 'dart:ui';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultPage({super.key, required this.resultData});

@override
Widget build(BuildContext context) {
  final leafType = resultData["prediction"]?["leaf_type"] ?? "Unknown Leaf";
  final disease = resultData["prediction"]?["health_label"] ?? "Unknown Condition";

  final leafConfidence = (resultData["confidence"]?["leaf_type"] ?? 0.0).toString();
  final diseaseConfidence = (resultData["confidence"]?["health_label"] ?? 0.0).toString();

  final description =
      "This medicinal leaf has been identified as **$leafType**.\n"
      "Current observed condition: **$disease**.\n\n"
      "Below are recommended care guidelines based on the detected condition.";

  final preventionTips = {
    "Healthy Leaf": "The leaf appears healthy 🌿.\n"
        "• Maintain normal watering schedule\n"
        "• Provide indirect sunlight\n"
        "• Ensure soil drains well\n"
        "• Continue regular plant care 💚",

    "Bacterial Spot": "A bacterial infection that spreads through leaf moisture.\n"
        "• Remove infected leaves immediately\n"
        "• Avoid spraying water directly on leaves\n"
        "• Increase air circulation around the plant\n"
        "• Keep surface moisture low",

    "Powdery Mildew": "A fungal infection causing white powder-like patches.\n"
        "• Improve air flow & reduce humidity\n"
        "• Avoid getting leaves wet during watering\n"
        "• Apply neem oil or baking soda spray\n"
        "• Keep plant in warm, ventilated spot",

    "Shot Hole": "This disease forms small holes in leaves.\n"
        "• Trim away affected leaf parts\n"
        "• Avoid excessive watering\n"
        "• Allow soil to dry slightly between watering",

    "Yellow Leaf": "Yellowing is often due to nutrient imbalance or root stress.\n"
        "• Do not overwater\n"
        "• Provide nitrogen & potassium rich fertilizer\n"
        "• Ensure the plant gets consistent indirect sunlight",

    "Spot Leaf": "Spotted leaves indicate early fungal activity.\n"
        "• Remove affected leaves\n"
        "• Spray neem oil lightly\n"
        "• Provide spacing and good airflow"
  };

  final prevent = preventionTips[disease] ??
      "General care recommended. Keep plant healthy with sunlight, airflow, and proper watering.";

  final supplementInfo = {
    "Healthy Leaf": "No supplements needed 👍 Continue normal care.",
    "Bacterial Spot": "Use Neem Oil or Copper fungicide (plant-safe only).",
    "Powdery Mildew": "Use Sulfur fungicide or Baking Soda/water spray.",
    "Shot Hole": "Use Neem oil + light organic fertilizer.",
    "Yellow Leaf": "Use nitrogen-rich compost like Vermicompost or Seaweed extract.",
    "Spot Leaf": "Apply Neem oil or mild organic antifungal treatments."
  };

  final supplementName = supplementInfo[disease] ??
      "Use natural neem oil spray or balanced organic fertilizer support.";

  final title = "$leafType • $disease";


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2F7EF), Color(0xFF7AD9A9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(title),
                const SizedBox(height: 30),
                _glassCard(Icons.local_florist, "Medicinal Plant & Disease", description, Colors.greenAccent.shade400),
                const SizedBox(height: 20),
                _glassCard(Icons.shield, "Prevention Tips", prevent, Colors.lightGreen.shade400),
                const SizedBox(height: 20),
                _glassCard(Icons.medication, "Suggested Supplement", supplementName, Colors.tealAccent.shade400),
                const SizedBox(height: 20),
                _glassCard(Icons.analytics, "Confidence",
                    "Medicinal Plant Prediction Confidence: $leafConfidence\nDisease Prediction Confidence: $diseaseConfidence",
                    Colors.green.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(String title) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800.withOpacity(0.85), Colors.green.shade400.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Widget _glassCard(IconData icon, String label, String content, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.55), color.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(content, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.95), height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

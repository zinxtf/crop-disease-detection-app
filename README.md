# 🌱 Crop Disease Detection App - Offline AI

Offline AI App for Farmers - Works without Internet

### App Flow
Camera/Gallery → 224x224 Preprocess → TFLite MobileNetV3-Small → Confidence Check → Hindi Advice

### Features
- Capture or Upload leaf photo
- On-device TFLite (5-8 MB) - No Internet Needed
- Preprocess 224x224 + Normalization
- Confidence <70% → Asks for clearer photo
- Grad-CAM Explainability
- Hindi + English Treatment
- Scan History

### Tech Stack
- Flutter, TFLite, PlantVillage 54k + PlantDoc
- Model: MobileNetV3-Small 2.5M params, quantized TFLite
- Accuracy: 92% Tomato Early Blight

### Build APK

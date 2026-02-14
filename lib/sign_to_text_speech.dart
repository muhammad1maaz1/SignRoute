import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class SignToTextSpeechScreen extends StatefulWidget {
  const SignToTextSpeechScreen({super.key});

  @override
  State<SignToTextSpeechScreen> createState() =>
      _SignToTextSpeechScreenState();
}

class _SignToTextSpeechScreenState extends State<SignToTextSpeechScreen> {
  static const Color brandYellow = Color(0xFFFFD400);

  // === Communication Channels ===
  static const MethodChannel _signChannel = MethodChannel('signroute/prediction');

  // Default text
  String conversationText = "Camera output will appear here...";
  String debugText = "Debug Status: Idle";

  CameraController? _cameraController;
  bool isRecording = false;
  bool _isProcessing = false;
  Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    _setupSignListener();
  }

  // ---------------- LINKING LOGIC (Yeh Function Link Karta Hai) ----------------
  void _setupSignListener() {
    _signChannel.setMethodCallHandler((call) async {
      if (!mounted) return;

      if (call.method == "onPrediction") {
        // === YEH RAHA LINK ===
        // Jab Android se jawab ayega, ye variable update hoga
        final String prediction = call.arguments;

        setState(() {
          conversationText = prediction; // Text Box ka text badal jayega
        });

      } else if (call.method == "onDebug") {
        final String status = call.arguments;
        setState(() {
          debugText = status;
        });
      }
    });
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) status = await Permission.camera.request();
    if (status.isGranted) startCamera();
  }

  Future<void> startCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
      setState(() { isRecording = true; });

      _cameraController!.startImageStream((CameraImage image) {
        if (_isProcessing) return;
        _isProcessing = true;

        if (_throttleTimer == null || !_throttleTimer!.isActive) {
          _throttleTimer = Timer(const Duration(milliseconds: 300), () {
            _sendImageToAndroid(image);
          });
        } else {
          _isProcessing = false;
        }
      });
    } catch (e) { print("Error: $e"); }
  }

  Future<void> _sendImageToAndroid(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      await _signChannel.invokeMethod('processFrame', {
        "bytes": bytes,
        "width": image.width,
        "height": image.height,
        "rotation": 270, // Infinix k liye 0 check karein
      });
    } catch (e) { print("Error: $e"); }
    finally { _isProcessing = false; }
  }

  Future<void> stopCamera() async {
    _throttleTimer?.cancel();
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    setState(() {
      _cameraController = null;
      isRecording = false;
      debugText = "Camera Stopped";
      conversationText = "Camera output will appear here..."; // Reset text
    });
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check karein k result aya hai ya nahi (Styling k liye)
    bool hasResult = conversationText != "Camera output will appear here...";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandYellow,
        title: const Text("Sign to Text/Speech", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Camera Box
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(22)),
                child: isRecording && _cameraController != null && _cameraController!.value.isInitialized
                    ? ClipRRect(borderRadius: BorderRadius.circular(22), child: CameraPreview(_cameraController!))
                    : const Center(child: Icon(Icons.camera_alt, size: 85, color: Colors.black54)),
              ),

              const SizedBox(height: 10),
              Text(debugText, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              const SizedBox(height: 40),

              // === OUTPUT TEXT BOX ===
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: hasResult ? Colors.yellow[50] : Colors.white, // Color change agar result aye
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: hasResult ? brandYellow : Colors.grey.shade300, width: hasResult ? 2 : 1),
                ),
                child: Text(
                  conversationText,
                  style: TextStyle(
                    fontSize: hasResult ? 24 : 14, // Sign aya to Bada Font
                    fontWeight: hasResult ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 60),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isRecording ? stopCamera : requestCameraPermission,
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: isRecording ? Colors.redAccent : brandYellow.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Text(
                            isRecording ? "Stop Recording" : "Record Signs",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(40)),
                      child: const Center(child: Text("Play as Speech", style: TextStyle(fontWeight: FontWeight.w600))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
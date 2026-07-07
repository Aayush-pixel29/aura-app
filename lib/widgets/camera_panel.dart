import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CameraPanel extends StatefulWidget {
  final Function(String base64Image) onFrameCaptured;
  final bool isAnalyzing;
  
  const CameraPanel({
    super.key, 
    required this.onFrameCaptured,
    required this.isAnalyzing,
  });

  @override
  State<CameraPanel> createState() => _CameraPanelState();
}

class _CameraPanelState extends State<CameraPanel> {
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvasElement;
  StreamSubscription? _streamSubscription;
  Timer? _captureTimer;
  bool _hasPermission = false;
  bool _error = false;
  String _viewId = '';

  @override
  void initState() {
    super.initState();
    _viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
    _initializeWebcam();
  }

  Future<void> _initializeWebcam() async {
    try {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // Register the video element as a platform view
      ui.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => _videoElement!,
      );

      // Request camera access
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640},
          'height': {'ideal': 480}
        }
      });

      if (stream != null) {
        _videoElement!.srcObject = stream;
        _canvasElement = html.CanvasElement(width: 640, height: 480);
        
        setState(() {
          _hasPermission = true;
        });

        // Start capture loop
        _startCaptureLoop();
      } else {
        setState(() {
          _error = true;
        });
      }
    } catch (e) {
      print("Camera init error: $e");
      setState(() {
        _error = true;
      });
    }
  }

  void _startCaptureLoop() {
    _captureTimer?.cancel();
    // Capture a frame every 3 seconds for analysis if active
    _captureTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (widget.isAnalyzing) {
        _captureFrame();
      }
    });
  }

  void _captureFrame() {
    if (_videoElement == null || _canvasElement == null) return;
    
    final context = _canvasElement!.context2D;
    
    // Draw current video frame to canvas
    context.drawImage(_videoElement!, 0, 0);
    
    // Convert canvas to base64 jpeg
    final dataUrl = _canvasElement!.toDataUrl('image/jpeg', 0.85);
    widget.onFrameCaptured(dataUrl);
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _streamSubscription?.cancel();
    if (_videoElement?.srcObject != null) {
      final stream = _videoElement!.srcObject as html.MediaStream;
      stream.getTracks().forEach((track) => track.stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, color: Colors.redAccent, size: 40),
              SizedBox(height: 8),
              Text(
                "Camera access denied or unavailable",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1A35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF00E5FF)),
              SizedBox(height: 16),
              Text(
                "Requesting webcam access...",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isAnalyzing ? const Color(0xFF00E5FF) : const Color(0xFF7B61FF).withOpacity(0.3),
          width: widget.isAnalyzing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isAnalyzing ? const Color(0xFF00E5FF) : const Color(0xFF7B61FF)).withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            HtmlElementView(viewType: _viewId),
            
            // Live scanning indicator overlay
            if (widget.isAnalyzing)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Scanner Line Animation
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          height: 3,
                          color: const Color(0xFF00E5FF),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .slideY(
                            begin: 0,
                            end: 150, // Approx height scale
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .slideY(
                            begin: 150,
                            end: 0,
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                ),
              ),
              
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isAnalyzing ? const Color(0xFF00E5FF) : Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isAnalyzing ? "Analyzing mood..." : "Live Feed",
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
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

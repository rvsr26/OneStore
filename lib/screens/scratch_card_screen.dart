import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart'; // 📦 Add to pubspec.yaml
import 'package:confetti/confetti.dart';   // 📦 Add to pubspec.yaml

class ScratchCardDialog extends StatefulWidget {
  @override
  _ScratchCardDialogState createState() => _ScratchCardDialogState();
}

class _ScratchCardDialogState extends State<ScratchCardDialog> {
  late ConfettiController _confettiController;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Allow confetti to fly outside
        children: [
          // --- MAIN CARD ---
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 300,
              height: 350,
              color: Colors.white,
              child: Scratcher(
                brushSize: 50,
                threshold: 50,
                color: Colors.indigo, // The "Scratch me" surface color
                accuracy: ScratchAccuracy.low,
                onChange: (value) {
                  // Optional: Haptic feedback here
                },
                onThreshold: () {
                  if (!_isRevealed) {
                    setState(() => _isRevealed = true);
                    _confettiController.play();
                  }
                },
                child: Container(
                  width: 300,
                  height: 350,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Winning Content (Hidden initially)
                      Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                      SizedBox(height: 15),
                      Text(
                        "WOOHOO!", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)
                      ),
                      SizedBox(height: 10),
                      Text(
                        "You won ₹50 Cashback!", 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Added to your wallet", 
                        style: TextStyle(fontSize: 12, color: Colors.grey)
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12)
                        ),
                        child: Text("Claim Reward", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- CONFETTI BLAST (Top Layer) ---
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // Blast everywhere
              shouldLoop: false, 
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              createParticlePath: drawStar, // Optional: Draw stars
            ),
          ),
        ],
      ),
    );
  }

  // ✨ Helper: Custom Confetti Shape (Star)
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (3.141592653589793 / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * -1 * (step).abs(), halfWidth + externalRadius * (step).abs()); // Simplified for brevity, basic star logic
      path.lineTo(halfWidth + internalRadius * -1 * (step + halfDegreesPerStep).abs(), halfWidth + internalRadius * (step + halfDegreesPerStep).abs());
    }
    path.close();
    return path;
  }
}
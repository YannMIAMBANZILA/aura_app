import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class AuraHunterGame extends StatefulWidget {
  const AuraHunterGame({super.key});

  @override
  State<AuraHunterGame> createState() => _AuraHunterGameState();
}

class _AuraHunterGameState extends State<AuraHunterGame> {
  int _score = 0;
  Timer? _timer;
  double _x = 0;
  double _y = 0;
  bool _isAura = true;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Delai pour laisser la page s'afficher complètement
    Future.delayed(const Duration(milliseconds: 500), _startSpawning);
  }

  void _startSpawning() {
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      setState(() {
        _isAura = _random.nextDouble() > 0.25; // 75% chance Aura, 25% piège
        // On empêche les éléments de sortir de l'écran (approximativement)
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        // On laisse une marge
        _x = _random.nextDouble() * (screenWidth - 100) + 20; 
        _y = _random.nextDouble() * (screenHeight - 300) + 20; 
      });
    });
  }

  void _onTap(bool isAura) {
    setState(() {
      if (isAura) {
        _score++;
      } else {
        _score = max(0, _score - 2); // Pénalité pour le piège !
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
             content: Text("Aïe, c'était un piège ! -2 points"),
             backgroundColor: Colors.redAccent,
             duration: Duration(milliseconds: 500),
          )
        );
      }
      // Hide the element after tap to avoid rapid fire
      _x = -100;
      _y = -100;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                const Text("Mini-jeu: Chasseur d'Aura ! (Score local)", style: TextStyle(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Score : $_score", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    left: _x,
                    top: _y,
                    child: GestureDetector(
                      onTap: () => _onTap(_isAura),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isAura ? const Color(0xFF00E5FF).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                          border: Border.all(color: _isAura ? const Color(0xFF00E5FF) : Colors.redAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: (_isAura ? const Color(0xFF00E5FF) : Colors.redAccent).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                        child: Icon(
                          _isAura ? Icons.auto_awesome : Icons.warning_amber_rounded,
                          color: _isAura ? const Color(0xFF00E5FF) : Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ],
    );
  }
}

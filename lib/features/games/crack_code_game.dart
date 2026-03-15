import 'package:flutter/material.dart';
import 'dart:math';

class CrackCodeGame extends StatefulWidget {
  const CrackCodeGame({super.key});

  @override
  State<CrackCodeGame> createState() => _CrackCodeGameState();
}

class _CrackCodeGameState extends State<CrackCodeGame> {
  late int _targetCode;
  late List<String> _hints;
  final TextEditingController _controller = TextEditingController();
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  void _generateCode() {
    _targetCode = Random().nextInt(90) + 10; // De 10 à 99
    _hints = [];
    int tens = _targetCode ~/ 10;
    int units = _targetCode % 10;
    
    // Indices de base
    if (_targetCode > 50) {
      _hints.add("Plus grand que 50");
    } else {
      _hints.add("Plus petit ou égal à 50");
    }
    
    if (_targetCode % 2 == 0) {
      _hints.add("C'est un nombre pair");
    } else {
      _hints.add("C'est un nombre impair");
    }
    
    // Indices de difficulté
    if (Random().nextBool()) {
      _hints.add("Finit par $units");
    } else {
      _hints.add("Commence par $tens");
    }

    // Un autre indice sur la somme des chiffres ? (un peu plus dur)
    if (Random().nextBool() && _hints.length < 3) {
      _hints.add("Somme des chiffres : ${tens + units}");
    }
    
    if (_hints.length < 3) {
      if (units > 5) _hints.add("Le dernier chiffre est strictement plus grand que 5");
      else _hints.add("Le dernier chiffre est petit (<= 5)");
    }

    _hints.shuffle();
    _hints = _hints.take(3).toList();
    
    _controller.clear();
    setState(() {});
  }

  void _checkCode() {
    if (_controller.text == _targetCode.toString()) {
      setState(() {
        _score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Code trouvé ! 🔓"),
          backgroundColor: Color(0xFF00E5FF),
          duration: Duration(milliseconds: 1000),
        )
      );
      _generateCode();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Oups, essaie encore !"),
          backgroundColor: Colors.redAccent,
          duration: Duration(milliseconds: 1000),
        )
      );
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Mini-jeu: Crack le code ! (Score local)", style: TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 8),
              Text("Score : $_score", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: _hints.map((hint) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF00E5FF), size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(hint, style: const TextStyle(color: Colors.white, fontSize: 18))),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 36, letterSpacing: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    hintText: "--",
                    hintStyle: const TextStyle(color: Colors.white24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _checkCode(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                child: const Text("Tenter de déverrouiller", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

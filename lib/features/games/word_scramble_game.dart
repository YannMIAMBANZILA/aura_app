import 'package:flutter/material.dart';
import 'dart:math';

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({super.key});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  final List<String> _words = [
    "MATHS", "LIVRE", "CLASSE", "ECOLE", 
    "COURS", "LECON", "SAVOIR", "EXAMEN", 
    "CRAYON", "PAPIER"
  ];
  late String _currentWord;
  late String _scrambledWord;
  final TextEditingController _controller = TextEditingController();
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _nextWord();
  }

  void _nextWord() {
    _currentWord = _words[Random().nextInt(_words.length)];
    List<String> chars = _currentWord.split('');
    chars.shuffle();
    while (chars.join('') == _currentWord) {
      chars.shuffle(); // Ensure it scrambled
    }
    _scrambledWord = chars.join('');
    _controller.clear();
    setState(() {});
  }

  void _checkWord() {
    if (_controller.text.toUpperCase().trim() == _currentWord) {
      setState(() {
        _score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bravo ! Mot trouvé 🎉"),
          backgroundColor: Color(0xFF00E5FF),
          duration: Duration(milliseconds: 1000),
        )
      );
      _nextWord();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Oups, ce n'est pas ça !"),
          backgroundColor: Colors.redAccent,
          duration: Duration(milliseconds: 1000),
        )
      );
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
              const Text("Mini-jeu: Mot mêlé ! (Score local)", style: TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 8),
              Text("Score : $_score", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  _scrambledWord,
                  style: const TextStyle(color: Colors.white, fontSize: 48, letterSpacing: 8, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 5),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintText: "Taper ici",
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  if (val.length == _currentWord.length) {
                    _checkWord();
                  }
                },
                onSubmitted: (_) => _checkWord(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: const Text("Valider", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

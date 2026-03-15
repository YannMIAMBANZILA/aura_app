import 'package:flutter/material.dart';
import 'dart:math';

import 'word_scramble_game.dart';
import 'crack_code_game.dart';
import 'aura_hunter_game.dart';
import 'express_maze_game.dart';

class LoadingGameScreen extends StatefulWidget {
  final Future<Map<String, dynamic>> lessonFuture;
  final String title;

  const LoadingGameScreen({
    super.key,
    required this.lessonFuture,
    this.title = "Génération du cours...",
  });

  @override
  State<LoadingGameScreen> createState() => _LoadingGameScreenState();
}

class _LoadingGameScreenState extends State<LoadingGameScreen> {
  bool _isReady = false;
  Map<String, dynamic>? _lessonData;
  late Widget _randomGame;

  @override
  void initState() {
    super.initState();
    _pickRandomGame();
    _listenToFuture();
  }

  void _pickRandomGame() {
    final games = [
      const WordScrambleGame(),
      const CrackCodeGame(),
      const AuraHunterGame(),
      const ExpressMazeGame(),
    ];
    _randomGame = games[Random().nextInt(games.length)];
  }

  Future<void> _listenToFuture() async {
    try {
      final result = await widget.lessonFuture;
      if (mounted) {
        setState(() {
          _isReady = true;
          _lessonData = result;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la génération: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent physical back button during loading
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Hide back button
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: _randomGame,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              top: _isReady ? 60 : -250,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "✨ Ton cours est prêt !",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Return data when user is ready
                          Navigator.pop(context, _lessonData);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Y aller",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
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

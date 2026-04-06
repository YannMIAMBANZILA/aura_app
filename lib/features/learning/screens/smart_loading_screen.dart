import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class EducationalFact {
  final String title;
  final String description;
  final IconData iconData;

  const EducationalFact({
    required this.title,
    required this.description,
    required this.iconData,
  });
}

const List<EducationalFact> _facts = [
  EducationalFact(
    title: "LE SAVAIS-TU ?",
    description: "Si tu pouvais plier une feuille de papier 42 fois, son épaisseur atteindrait la Lune !",
    iconData: Icons.rocket_launch,
  ),
  EducationalFact(
    title: "LE SAVAIS-TU ?",
    description: "Cléopâtre a vécu plus près de l'invention de l'iPhone que de la construction des grandes pyramides !",
    iconData: Icons.history_edu,
  ),
  EducationalFact(
    title: "LE SAVAIS-TU ?",
    description: "L'être humain partage environ 50% de son ADN avec... une banane !",
    iconData: Icons.biotech,
  ),
  EducationalFact(
    title: "LE SAVAIS-TU ?",
    description: "Une journée sur Vénus dure plus longtemps qu'une année entière sur cette même planète.",
    iconData: Icons.public,
  ),
  EducationalFact(
    title: "LE SAVAIS-TU ?",
    description: "Les pieuvres ont 3 cœurs et leur sang est bleu car il est basé sur le cuivre, pas le fer.",
    iconData: Icons.water_drop,
  ),
];

class SmartLoadingScreen<T> extends StatefulWidget {
  final Future<T> future;
  final void Function(T result) onSuccess;
  final void Function(Object error)? onError;
  final String loadingText;

  const SmartLoadingScreen({
    super.key,
    required this.future,
    required this.onSuccess,
    this.onError,
    this.loadingText = "Laura génère tes questions...",
  });

  @override
  State<SmartLoadingScreen<T>> createState() => _SmartLoadingScreenState<T>();
}

class _SmartLoadingScreenState<T> extends State<SmartLoadingScreen<T>> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _executeFuture();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _facts.length;
        });
      }
    });
  }

  Future<void> _executeFuture() async {
    try {
      final result = await widget.future;
      if (mounted) {
        widget.onSuccess(result);
      }
    } catch (e) {
      if (mounted) {
        if (widget.onError != null) {
          widget.onError!(e);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Une erreur est survenue: $e"), backgroundColor: AuraColors.softCoral),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildFactCard(_facts[_currentIndex]),
                  ),
                ),
              ),
              Column(
                children: [
                  const CircularProgressIndicator(color: Color(0xFF00E5FF)),
                  const SizedBox(height: 16),
                  Text(
                    widget.loadingText,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactCard(EducationalFact fact) {
    return Container(
      key: ValueKey<int>(_currentIndex),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              fact.iconData,
              size: 48,
              color: const Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            fact.title,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF00E5FF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            fact.description,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

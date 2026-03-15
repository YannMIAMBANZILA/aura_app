import 'package:flutter/material.dart';

class ExpressMazeGame extends StatefulWidget {
  const ExpressMazeGame({super.key});

  @override
  State<ExpressMazeGame> createState() => _ExpressMazeGameState();
}

class _ExpressMazeGameState extends State<ExpressMazeGame> {
  static const int _gridSize = 6;
  int _playerX = 0;
  int _playerY = 0;
  int _goalX = 5;
  int _goalY = 5;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _playerX = 0;
      _playerY = 0;
      // Change l'arrivée de manière aléatoire mais pas sur nous
      _goalX = (_gridSize - 1);
      _goalY = (_gridSize - 1);
    });
  }

  void _move(int dx, int dy) {
    setState(() {
      int newX = _playerX + dx;
      int newY = _playerY + dy;

      if (newX >= 0 && newX < _gridSize && newY >= 0 && newY < _gridSize) {
        _playerX = newX;
        _playerY = newY;

        if (_playerX == _goalX && _playerY == _goalY) {
          _score++;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Arrivée atteinte ! +1 🏁"),
              backgroundColor: Color(0xFF00E5FF),
              duration: Duration(milliseconds: 800),
            )
          );
          _resetGame();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Mini-jeu: Labyrinthe Express ! (Score local)", style: TextStyle(color: Colors.white54, fontSize: 16)),
        const SizedBox(height: 8),
        Text("Score : $_score", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) _move(0, -1); // Up
              else if (details.primaryVelocity! > 0) _move(0, 1); // Down
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) _move(-1, 0); // Left
              else if (details.primaryVelocity! > 0) _move(1, 0); // Right
            },
            child: Container(
              color: Colors.transparent, // Important pour le drag
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) {
                      int x = index % _gridSize;
                      int y = index ~/ _gridSize;
                      
                      bool isPlayer = (x == _playerX && y == _playerY);
                      bool isGoal = (x == _goalX && y == _goalY);

                      return Container(
                        decoration: BoxDecoration(
                          color: isPlayer ? const Color(0xFF00E5FF) : 
                                 isGoal ? Colors.greenAccent.withOpacity(0.8) :
                                 Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isPlayer ? [
                            BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 10, spreadRadius: 1)
                          ] : null,
                        ),
                        child: isPlayer ? const Icon(Icons.circle, color: Color(0xFF0F172A), size: 16) :
                               isGoal ? const Icon(Icons.flag, color: Color(0xFF0F172A), size: 20) : null,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text("Swipe / Glisse pour te déplacer", style: TextStyle(color: Colors.white38, fontSize: 16)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => _move(-1, 0), icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF)), iconSize: 40,),
            Column(
              children: [
                IconButton(onPressed: () => _move(0, -1), icon: const Icon(Icons.keyboard_arrow_up, color: Color(0xFF00E5FF)), iconSize: 50,),
                IconButton(onPressed: () => _move(0, 1), icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00E5FF)), iconSize: 50,),
              ],
            ),
            IconButton(onPressed: () => _move(1, 0), icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF00E5FF)), iconSize: 40,),
          ],
        )
      ],
    );
  }
}

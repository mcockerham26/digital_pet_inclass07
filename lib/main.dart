import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const DigitalPetScreen(),
    );
  }
}

class DigitalPetScreen extends StatefulWidget {
  const DigitalPetScreen({super.key});

  @override
  State<DigitalPetScreen> createState() => _DigitalPetScreenState();
}

class _DigitalPetScreenState extends State<DigitalPetScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Pip');

  int happiness = 50;
  int hunger = 50;
  int energy = 70;

  Timer? _hungerTimer;
  Timer? _winTimer;

  bool hasWon = false;
  bool hasLost = false;

  bool get gameOver => hasWon || hasLost;

  String get mood {
    if (happiness > 70) {
      return 'Happy';
    } else if (happiness >= 30) {
      return 'Neutral';
    } else {
      return 'Unhappy';
    }
  }

  Color get moodColor {
    if (happiness > 70) {
      return Colors.green;
    } else if (happiness >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  int _clampMeter(int value) {
    return value.clamp(0, 100);
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted || gameOver) {
          return;
        }

        setState(() {
          if (hunger >= 100) {
            hunger = 100;
            happiness = _clampMeter(happiness - 20);
          } else {
            hunger = _clampMeter(hunger + 5);
          }
        });

        _checkGameState();
      },
    );
  }

  void _feedPet() {
    if (gameOver) {
      return;
    }

    setState(() {
      hunger = _clampMeter(hunger - 20);

      if (hunger < 50) {
        happiness = _clampMeter(happiness + 5);
      }
    });

    _checkGameState();
  }

  void _playWithPet() {
    if (gameOver) {
      return;
    }

    if (energy < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pip is too tired to play!'),
        ),
      );
      return;
    }

    setState(() {
      happiness = _clampMeter(happiness + 15);
      hunger = _clampMeter(hunger + 10);
      energy = _clampMeter(energy - 10);
    });

    _checkGameState();
  }

  void _restPet() {
    if (gameOver) {
      return;
    }

    setState(() {
      energy = _clampMeter(energy + 20);
      hunger = _clampMeter(hunger + 5);
    });

    _checkGameState();
  }

  void _runActivity() {
    if (gameOver) {
      return;
    }

    if (energy < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough energy to run!'),
        ),
      );
      return;
    }

    setState(() {
      energy = _clampMeter(energy - 20);
      hunger = _clampMeter(hunger + 10);
      happiness = _clampMeter(happiness + 10);
    });

    _checkGameState();
  }

  void _sleepActivity() {
    if (gameOver) {
      return;
    }

    setState(() {
      energy = _clampMeter(energy + 30);
      hunger = _clampMeter(hunger + 5);
    });

    _checkGameState();
  }

  void _checkGameState() {
    if (!mounted || gameOver) {
      return;
    }

    // Loss condition
    if (hunger >= 100 && happiness <= 10) {
      _winTimer?.cancel();
      _winTimer = null;
      _hungerTimer?.cancel();

      setState(() {
        hasLost = true;
      });

      return;
    }

    // Win condition:
    // Happiness must remain ABOVE 80 continuously for 3 minutes.
    if (happiness > 80) {
      _winTimer ??= Timer(
        const Duration(minutes: 3),
        () {
          if (!mounted || gameOver) {
            return;
          }

          if (happiness > 80) {
            _hungerTimer?.cancel();

            setState(() {
              hasWon = true;
            });
          }

          _winTimer = null;
        },
      );
    } else {
      _winTimer?.cancel();
      _winTimer = null;
    }
  }

  void _resetPet() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _winTimer = null;

    setState(() {
      happiness = 50;
      hunger = 50;
      energy = 70;
      hasWon = false;
      hasLost = false;
      _nameController.text = 'Pip';
    });

    _startHungerTimer();
  }

  Widget _buildMeter(
    String label,
    int value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                '$label: $value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
              ),

              const SizedBox(height: 24),

              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  moodColor,
                  BlendMode.modulate,
                ),
                child: Image.asset(
                  'assets/pet.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Mood: $mood',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: moodColor == Colors.yellow
                      ? Colors.orange.shade800
                      : moodColor,
                ),
              ),

              const SizedBox(height: 16),

              if (hasWon)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'You Win! ${_nameController.text} stayed happy!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              if (hasLost)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Game Over! ${_nameController.text} needs better care.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              _buildMeter(
                'Happiness',
                happiness,
                Icons.sentiment_satisfied_alt,
              ),

              _buildMeter(
                'Hunger',
                hunger,
                Icons.restaurant,
              ),

              _buildMeter(
                'Energy',
                energy,
                Icons.battery_charging_full,
              ),

              const SizedBox(height: 20),

              const Text(
                'Care',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: gameOver ? null : _feedPet,
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Feed'),
                  ),
                  ElevatedButton.icon(
                    onPressed: gameOver ? null : _playWithPet,
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('Play'),
                  ),
                  ElevatedButton.icon(
                    onPressed: gameOver ? null : _restPet,
                    icon: const Icon(Icons.hotel),
                    label: const Text('Rest'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: gameOver ? null : _runActivity,
                    icon: const Icon(Icons.directions_run),
                    label: const Text('Run'),
                  ),
                  ElevatedButton.icon(
                    onPressed: gameOver ? null : _sleepActivity,
                    icon: const Icon(Icons.bedtime),
                    label: const Text('Sleep'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              OutlinedButton.icon(
                onPressed: _resetPet,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }
}
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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

  bool get gameOver => hasWon || hasLost;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGameState();
    });
  }

  int _clampMeter(int value) {
    return value.clamp(0, 100);
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted || gameOver) return;

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
    if (gameOver) return;

    setState(() {
      hunger = _clampMeter(hunger - 20);

      if (hunger < 50) {
        happiness = _clampMeter(happiness + 5);
      }
    });

    _checkGameState();
  }

  void _playWithPet() {
    if (gameOver) return;

    if (energy < 10) {
      _showMessage('Your pet is too tired to play!');
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
    if (gameOver) return;

    setState(() {
      energy = _clampMeter(energy + 20);
      hunger = _clampMeter(hunger + 5);
    });

    _checkGameState();
  }

  void _runActivity() {
    if (gameOver) return;

    if (energy < 20) {
      _showMessage('Your pet does not have enough energy to run!');
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
    if (gameOver) return;

    setState(() {
      energy = _clampMeter(energy + 30);
      hunger = _clampMeter(hunger + 5);
    });

    _checkGameState();
  }

  void _checkGameState() {
    if (!mounted) return;

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
      if (_winTimer == null) {
        _winTimer = Timer(
          const Duration(minutes: 3),
          () {
            if (!mounted || gameOver) return;

            if (happiness > 80) {
              _hungerTimer?.cancel();

              setState(() {
                hasWon = true;
              });
            }

            _winTimer = null;
          },
        );
      }
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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMeter({
    required String label,
    required int value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value / 100,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String statusMessage;

    if (hasWon) {
      statusMessage = 'You win! Your pet stayed very happy!';
    } else if (hasLost) {
      statusMessage = 'Game Over! Your pet needs better care.';
    } else {
      statusMessage = 'Mood: $mood';
    }

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
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                statusMessage,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: moodColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              _buildMeter(
                label: 'Happiness',
                value: happiness,
              ),

              _buildMeter(
                label: 'Hunger',
                value: hunger,
              ),

              _buildMeter(
                label: 'Energy',
                value: energy,
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Care',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: gameOver ? null : _feedPet,
                      icon: const Icon(Icons.restaurant),
                      label: const Text('Feed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: gameOver ? null : _playWithPet,
                      icon: const Icon(Icons.sports_esports),
                      label: const Text('Play'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: gameOver ? null : _restPet,
                      icon: const Icon(Icons.bedtime),
                      label: const Text('Rest'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: gameOver ? null : _runActivity,
                      icon: const Icon(Icons.directions_run),
                      label: const Text('Run'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: gameOver ? null : _sleepActivity,
                      icon: const Icon(Icons.hotel),
                      label: const Text('Sleep'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetPet,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset Pet'),
                ),
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
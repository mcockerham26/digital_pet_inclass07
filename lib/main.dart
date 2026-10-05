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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const DigitalPetPage(),
    );
  }
}

class DigitalPetPage extends StatefulWidget {
  const DigitalPetPage({super.key});

  @override
  State<DigitalPetPage> createState() => _DigitalPetPageState();
}

class _DigitalPetPageState extends State<DigitalPetPage> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Pip');

  String _petName = 'Pip';

  int _happiness = 50;
  int _hunger = 50;
  int _energy = 70;

  bool _gameOver = false;
  bool _hasWon = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  String get _mood {
    if (_happiness > 70) {
      return 'Happy';
    } else if (_happiness >= 30) {
      return 'Neutral';
    } else {
      return 'Unhappy';
    }
  }

  Color get _moodColor {
    if (_happiness > 70) {
      return Colors.green;
    } else if (_happiness >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String get _petMessage {
    if (_gameOver) {
      return 'I need a rest.';
    }

    if (_hasWon) {
      return 'Best day ever!';
    }

    if (_hunger > 80) {
      return "I'm starving!";
    }

    if (_energy < 20) {
      return 'So sleepy...';
    }

    if (_happiness <= 30) {
      return 'Play with me?';
    }

    return "Hi, I'm $_petName!";
  }

  void _confirmName() {
    final newName = _nameController.text.trim();

    if (newName.isNotEmpty) {
      setState(() {
        _petName = newName;
      });
    }
  }

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    final nextHunger = _clampMeter(_hunger - 10);
    final happinessChange = nextHunger < 30 ? -20 : 10;

    setState(() {
      _hunger = nextHunger;
      _happiness = _clampMeter(
        _happiness + happinessChange,
      );
    });

    _updateOutcome();
  }

  void _playWithPet() {
    if (_gameOver || _hasWon) return;

    if (_energy < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_petName is too tired to play! Let your pet rest.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _happiness = _clampMeter(_happiness + 15);
      _hunger = _clampMeter(_hunger + 5);
      _energy = _clampMeter(_energy - 10);
    });

    _updateOutcome();
  }

  void _restPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _energy = _clampMeter(_energy + 20);
      _hunger = _clampMeter(_hunger + 5);
    });

    _updateOutcome();
  }

  // Advanced Feature #2: Activity Selection
  void _runActivity() {
    if (_gameOver || _hasWon) return;

    if (_energy < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_petName does not have enough energy to run!',
          ),
        ),
      );
      return;
    }

    setState(() {
      _happiness = _clampMeter(_happiness + 10);
      _hunger = _clampMeter(_hunger + 10);
      _energy = _clampMeter(_energy - 15);
    });

    _updateOutcome();
  }

  void _sleepActivity() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _energy = _clampMeter(_energy + 30);
      _hunger = _clampMeter(_hunger + 10);
      _happiness = _clampMeter(_happiness + 5);
    });

    _updateOutcome();
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    _hungerTimer?.cancel();

    setState(() {
      _happiness = 50;
      _hunger = 50;
      _energy = 70;
      _gameOver = false;
      _hasWon = false;
    });

    _startHungerTimer();
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (!mounted || _gameOver || _hasWon) {
          timer.cancel();
          return;
        }

        setState(() {
          if (_hunger + 5 > 100) {
            _hunger = 100;
            _happiness = _clampMeter(
              _happiness - 20,
            );
          } else {
            _hunger += 5;
          }
        });

        _updateOutcome();
      },
    );
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon) return;

    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(
      const Duration(minutes: 3),
      () {
        _highMoodTimer = null;

        if (!mounted ||
            _gameOver ||
            _happiness <= 80) {
          return;
        }

        setState(() {
          _hasWon = true;
        });

        _hungerTimer?.cancel();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final careDisabled = _gameOver || _hasWon;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Digital Pet'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _petMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _moodColor,
                  BlendMode.modulate,
                ),
                child: Image.asset(
                  'assets/pet.png',
                  height: 200,
                  fit: BoxFit.contain,
                  semanticLabel: '$_mood digital pet',
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Mood: $_mood',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _moodColor,
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _confirmName,
                child: const Text('Confirm Name'),
              ),

              const SizedBox(height: 25),

              Text(
                'Happiness: $_happiness',
                style: const TextStyle(fontSize: 18),
              ),
              LinearProgressIndicator(
                value: _happiness / 100,
              ),

              const SizedBox(height: 18),

              Text(
                'Hunger: $_hunger',
                style: const TextStyle(fontSize: 18),
              ),
              LinearProgressIndicator(
                value: _hunger / 100,
              ),

              const SizedBox(height: 18),

              Text(
                'Energy: $_energy',
                style: const TextStyle(fontSize: 18),
              ),
              LinearProgressIndicator(
                value: _energy / 100,
              ),

              const SizedBox(height: 25),

              if (_hasWon)
                const Text(
                  'You Win! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (_gameOver)
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 15),

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
                  ElevatedButton(
                    onPressed:
                        careDisabled ? null : _feedPet,
                    child: const Text('Feed'),
                  ),
                  ElevatedButton(
                    onPressed:
                        careDisabled ? null : _playWithPet,
                    child: const Text('Play'),
                  ),
                  ElevatedButton(
                    onPressed:
                        careDisabled ? null : _restPet,
                    child: const Text('Rest'),
                  ),
                ],
              ),

              const SizedBox(height: 25),

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
                    onPressed:
                        careDisabled ? null : _runActivity,
                    icon: const Icon(Icons.directions_run),
                    label: const Text('Run'),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        careDisabled ? null : _sleepActivity,
                    icon: const Icon(Icons.bedtime),
                    label: const Text('Sleep'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              OutlinedButton.icon(
                onPressed: _resetPet,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
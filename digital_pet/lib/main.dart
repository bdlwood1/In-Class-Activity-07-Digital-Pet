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
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
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
  // Starting pet values
  int happiness = 50;
  int hunger = 50;

  // Pet name
  String petName = 'My Pet';
  final TextEditingController nameController = TextEditingController();

  // Session state
  bool sessionRunning = true;

  // Timers
  Timer? hungerTimer;
  Timer? winTimer;

  // Tracks continuous time above 80 happiness
  int happySeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  // Keeps meters between 0 and 100.
  int _clampMeter(int value) {
    return value.clamp(0, 100);
  }

  // Starts the timers used by the pet.
  void _startTimers() {
    hungerTimer?.cancel();
    winTimer?.cancel();

    // Hunger increases by 5 every 30 seconds.
    hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!sessionRunning) return;

      setState(() {
        // Reaching 100 normally does not cause a penalty.
        // A later tick while hunger is already full
        // reduces happiness by 20.
        if (hunger + 5 > 100) {
          hunger = 100;
          happiness = _clampMeter(happiness - 20);
        } else {
          hunger += 5;
        }
      });

      _checkLoss();
    });

    // Checks whether happiness has stayed above 80.
    winTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!sessionRunning) return;

      if (happiness > 80) {
        happySeconds++;

        // Three continuous minutes above 80 wins.
        if (happySeconds >= 180) {
          _showWin();
        }
      } else {
        happySeconds = 0;
      }
    });
  }

  // Confirms the name entered by the user.
  void _confirmName() {
    final newName = nameController.text.trim();

    if (newName.isNotEmpty) {
      setState(() {
        petName = newName;
      });

      nameController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  // Feed uses the suggested balance from the assignment.
  void _feedPet() {
    if (!sessionRunning) return;

    setState(() {
      final nextHunger = _clampMeter(hunger - 10);
      final happinessChange = nextHunger < 30 ? 20 : 10;

      hunger = nextHunger;
      happiness = _clampMeter(happiness + happinessChange);
    });

    _checkLoss();
  }

  // Team rule: Play raises happiness by 10.
  void _playWithPet() {
    if (!sessionRunning) return;

    setState(() {
      happiness = _clampMeter(happiness + 10);
    });

    _checkLoss();
  }

  // Restores the initial care state.
  void _resetPet() {
    setState(() {
      happiness = 50;
      hunger = 50;
      happySeconds = 0;
      sessionRunning = true;
    });

    _startTimers();
  }

  // Advanced feature: Session Controls
  void _toggleSession() {
    setState(() {
      sessionRunning = !sessionRunning;
    });
  }

  // Loss:
  // hunger is 100 AND happiness is 10 or lower.
  void _checkLoss() {
    if (hunger == 100 && happiness <= 10) {
      sessionRunning = false;

      hungerTimer?.cancel();
      winTimer?.cancel();

      _showOutcomeDialog(
        title: 'Game Over',
        message: '$petName became too hungry and unhappy.',
      );
    }
  }

  // Win:
  // happiness remains strictly above 80 for 3 minutes.
  void _showWin() {
    sessionRunning = false;

    hungerTimer?.cancel();
    winTimer?.cancel();

    _showOutcomeDialog(
      title: 'You Win!',
      message: '$petName stayed happy for 3 continuous minutes!',
    );
  }

  void _showOutcomeDialog({required String title, required String message}) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetPet();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Clean up resources owned by this State object.
    hungerTimer?.cancel();
    winTimer?.cancel();
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Temporary placeholder for Team 2's pet asset.
              const Icon(Icons.pets, size: 100),

              const SizedBox(height: 10),

              Text(
                petName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Editable pet name
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter pet name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _confirmName(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _confirmName,
                    child: const Text('Confirm'),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Text(
                'Happiness: $happiness / 100',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(value: happiness / 100, minHeight: 14),

              const SizedBox(height: 25),

              Text(
                'Hunger: $hunger / 100',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(value: hunger / 100, minHeight: 14),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: sessionRunning ? _feedPet : null,
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Feed'),
                  ),
                  ElevatedButton.icon(
                    onPressed: sessionRunning ? _playWithPet : null,
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('Play'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Advanced Feature: Session Controls
              ElevatedButton.icon(
                onPressed: _toggleSession,
                icon: Icon(sessionRunning ? Icons.pause : Icons.play_arrow),
                label: Text(
                  sessionRunning ? 'Pause Session' : 'Resume Session',
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _resetPet,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),

              const SizedBox(height: 20),

              Text(
                sessionRunning ? 'Session Running' : 'Session Paused',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: sessionRunning ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

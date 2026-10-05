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
  // Core pet state
  int happiness = 50;
  int hunger = 50;

  // Session state
  bool sessionRunning = true;

  // Timers
  Timer? hungerTimer;
  Timer? winTimer;

  // Tracks how long happiness has continuously stayed above 80
  int happySeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  // Keeps all meter values between 0 and 100.
  int _clampMeter(int value) {
    return value.clamp(0, 100);
  }

  // Starts the hunger and win-condition timers.
  void _startTimers() {
    hungerTimer?.cancel();
    winTimer?.cancel();

    // Hunger increases by 5 every 30 seconds.
    hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!sessionRunning) return;

      setState(() {
        hunger = _clampMeter(hunger + 5);
      });

      _checkLoss();
    });

    // Check the happiness win condition every second.
    winTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!sessionRunning) return;

      if (happiness > 80) {
        happySeconds++;

        // Happiness must remain above 80
        // continuously for 3 minutes.
        if (happySeconds >= 180) {
          _showWin();
        }
      } else {
        // Falling to 80 or below resets the streak.
        happySeconds = 0;
      }
    });
  }

  // Feed follows the suggested balance from the assignment.
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

  // Reset the entire care session.
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

  // Loss condition from the assignment:
  // Hunger = 100 AND Happiness <= 10.
  void _checkLoss() {
    if (hunger == 100 && happiness <= 10) {
      sessionRunning = false;

      hungerTimer?.cancel();
      winTimer?.cancel();

      _showOutcomeDialog(
        title: 'Game Over',
        message: 'Your pet became too hungry and unhappy.',
      );
    }
  }

  // Win condition:
  // Happiness stays above 80 for 3 continuous minutes.
  void _showWin() {
    sessionRunning = false;

    hungerTimer?.cancel();
    winTimer?.cancel();

    _showOutcomeDialog(
      title: 'You Win!',
      message: 'Your pet stayed happy for 3 continuous minutes!',
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
    // Required timer cleanup.
    hungerTimer?.cancel();
    winTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Temporary pet placeholder.
              // Team 2 can replace this with the pet asset.
              const Icon(Icons.pets, size: 120),

              const SizedBox(height: 20),

              const Text(
                'My Pet',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Happiness meter
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

              // Hunger meter
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

              // Feed and Play actions
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

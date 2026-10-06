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
        colorSchemeSeed: Colors.deepPurple,
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
  // ---------------- TEAM 1: CORE PET STATE ----------------

  int happiness = 50;
  int hunger = 50;

  String petName = 'My Pet';
  final TextEditingController nameController = TextEditingController();

  bool sessionRunning = true;

  Timer? hungerTimer;
  Timer? winTimer;

  int happySeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  int _clampMeter(int value) {
    return value.clamp(0, 100);
  }

  void _startTimers() {
    hungerTimer?.cancel();
    winTimer?.cancel();

    hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!sessionRunning) return;

      setState(() {
        if (hunger + 5 > 100) {
          hunger = 100;
          happiness = _clampMeter(happiness - 20);
        } else {
          hunger += 5;
        }
      });

      _checkLoss();
    });

    winTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!sessionRunning) return;

      if (happiness > 80) {
        happySeconds++;

        if (happySeconds >= 180) {
          _showWin();
        }
      } else {
        happySeconds = 0;
      }
    });
  }

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

  void _playWithPet() {
    if (!sessionRunning) return;

    setState(() {
      happiness = _clampMeter(happiness + 10);
    });

    _checkLoss();
  }

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

  void _showWin() {
    sessionRunning = false;

    hungerTimer?.cancel();
    winTimer?.cancel();

    _showOutcomeDialog(
      title: 'You Win!',
      message: '$petName stayed happy for 3 continuous minutes!',
    );
  }

  void _showOutcomeDialog({
    required String title,
    required String message,
  }) {
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

  // ---------------- TEAM 2: PET PERSONALITY ----------------

  // Required mood boundaries:
  // > 70 = Happy
  // 30-70 = Neutral
  // < 30 = Unhappy
  String get moodLabel {
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
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  IconData get moodIcon {
    if (happiness > 70) {
      return Icons.sentiment_very_satisfied;
    } else if (happiness >= 30) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  // Personality message is derived from the pet's current state.
  String get petMessage {
    if (!sessionRunning) {
      return '$petName is taking a little break.';
    }

    if (hunger >= 80) {
      return '$petName is really hungry!';
    }

    if (happiness < 30) {
      return '$petName wants some attention. Let\'s play!';
    }

    if (happiness > 80 && hunger < 40) {
      return '$petName is having the best day!';
    }

    if (happiness > 70) {
      return '$petName is feeling happy!';
    }

    return '$petName is doing okay.';
  }

  // Visual Polish effect #1:
  // Pet becomes slightly larger when happy and smaller when unhappy.
  double get petScale {
    if (happiness > 70) {
      return 1.06;
    } else if (happiness < 30) {
      return 0.94;
    }

    return 1.0;
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessibility: disable animations when the device requests
    // reduced motion.
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 350);

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
              // ---------------- TEAM 2 PET DISPLAY ----------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Visual Polish effect #1: animated pet size.
                    AnimatedScale(
                      scale: petScale,
                      duration: animationDuration,

                      // Required mood tint applied to transparent bunny.
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          moodColor,
                          BlendMode.modulate,
                        ),
                        child: Image.asset(
                          'assets/bunny.png',
                          height: 190,
                          fit: BoxFit.contain,
                          semanticLabel: 'Digital pet bunny',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      petName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Mood uses text + icon, not color alone.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          moodIcon,
                          color: moodColor,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          moodLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: moodColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Visual Polish effect #2:
                    // Smooth transition when the personality message changes.
                    AnimatedSwitcher(
                      duration: animationDuration,
                      child: Text(
                        petMessage,
                        key: ValueKey(petMessage),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- PET NAME ----------------

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

              // ---------------- HAPPINESS ----------------

              Text(
                'Happiness: $happiness / 100',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Visual Polish effect #3: smoothly animated meter.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: happiness / 100,
                ),
                duration: animationDuration,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 14,
                    borderRadius: BorderRadius.circular(10),
                  );
                },
              ),

              const SizedBox(height: 25),

              // ---------------- HUNGER ----------------

              Text(
                'Hunger: $hunger / 100',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: hunger / 100,
                ),
                duration: animationDuration,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 14,
                    borderRadius: BorderRadius.circular(10),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ---------------- CARE BUTTONS ----------------

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
                icon: Icon(
                  sessionRunning ? Icons.pause : Icons.play_arrow,
                ),
                label: Text(
                  sessionRunning
                      ? 'Pause Session'
                      : 'Resume Session',
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _resetPet,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    sessionRunning
                        ? Icons.play_circle
                        : Icons.pause_circle,
                    color: sessionRunning
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sessionRunning
                        ? 'Session Running'
                        : 'Session Paused',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sessionRunning
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
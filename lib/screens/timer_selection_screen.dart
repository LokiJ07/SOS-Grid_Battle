import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class TimerSelectionScreen extends StatefulWidget {
  final int gridSize;
  const TimerSelectionScreen({super.key, required this.gridSize});

  @override
  State<TimerSelectionScreen> createState() => _TimerSelectionScreenState();
}

class _TimerSelectionScreenState extends State<TimerSelectionScreen> {
  final TextEditingController _customController = TextEditingController();

  void _startGame(int? seconds) {
    context.read<GameProvider>().initGame(widget.gridSize, seconds);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Turn Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Choose turn time limit:",
                style: TextStyle(fontSize: 18)),
            const Text("Losing all 10 lives results in a loss.",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),
            _timerOption("No Timer (Infinite)", null),
            _timerOption("10 Seconds", 10),
            _timerOption("15 Seconds", 15),
            const Spacer(),
            TextField(
              controller: _customController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Custom Seconds",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  int? val = int.tryParse(_customController.text);
                  if (val != null && val > 0) {
                    _startGame(val);
                  }
                },
                child: const Text("USE CUSTOM TIMER"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerOption(String label, int? seconds) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        trailing: const Icon(Icons.timer),
        onTap: () => _startGame(seconds),
      ),
    );
  }
}

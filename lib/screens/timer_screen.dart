import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> _presetDurations = [10, 30, 60];
  int _selectedDuration = 10;
  bool _isRunning = false;
  int _remainingSeconds = 0;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _selectedDuration * 60;
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_isRunning && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _startTimer();
      } else if (_remainingSeconds == 0) {
        _playCompletionSound();
        setState(() {
          _isRunning = false;
          _remainingSeconds = _totalSeconds;
        });
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _playCompletionSound() async {
    await _audioPlayer.play(AssetSource('sounds/bell.mp3'));
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _presetDurations.map((duration) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: _isRunning
                        ? null
                        : () {
                            setState(() {
                              _selectedDuration = duration;
                              _totalSeconds = duration * 60;
                              _remainingSeconds = _totalSeconds;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDuration == duration
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    child: Text('${duration}m'),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRunning ? _stopTimer : _startTimer,
              child: Text(_isRunning ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
} 
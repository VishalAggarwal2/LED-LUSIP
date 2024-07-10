import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter LED Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'LED Control Panel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isRedOn = false;
  bool _isBlueOn = false;
  bool _isYellowOn = false;
  bool _isGreenOn = false;
  bool _allLightsOn = false;
  Color _backgroundColor = Colors.white;
  double _intensity = 1.0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _toggleSwitch(String color, bool value) async {
    setState(() {
      if (color == 'red') {
        _isRedOn = value;
      } else if (color == 'blue') {
        _isBlueOn = value;
      } else if (color == 'yellow') {
        _isYellowOn = value;
      } else if (color == 'green') {
        _isGreenOn = value;
      }

      // Update the background color based on the switch state
      if (_isRedOn) {
        _backgroundColor = Colors.redAccent.shade100;
      } else if (_isBlueOn) {
        _backgroundColor = Colors.blueAccent.shade100;
      } else if (_isYellowOn) {
        _backgroundColor = Colors.yellowAccent.shade100;
      } else if (_isGreenOn) {
        _backgroundColor = Colors.greenAccent.shade100;
      } else {
        _backgroundColor = Colors.white; // Default background color
      }
    });

    final response = await http.get(Uri.parse('http://192.168.4.1/move?color=$color&state=${value ? 'on' : 'off'}'));

    if (response.statusCode == 200) {
      print('Request sent successfully');
    } else {
      print('Failed to send request');
    }
  }

  Future<void> _toggleAllLights(bool value) async {
    setState(() {
      _isRedOn = value;
      _isBlueOn = value;
      _isYellowOn = value;
      _isGreenOn = value;
      _allLightsOn = value;

      // Update the background color based on the switch state
      if (value) {
        _backgroundColor = Colors.white;
      } else {
        _backgroundColor = Colors.white; // Default background color
      }
    });

    final response = await http.get(Uri.parse('http://192.168.4.1/move?all=${value ? 'on' : 'off'}'));

    if (response.statusCode == 200) {
      print('Request sent successfully');
    } else {
      print('Failed to send request');
    }
  }

  Future<void> _blinkLights() async {
    final response = await http.get(Uri.parse('http://192.168.4.1/move?blink=true'));

    if (response.statusCode == 200) {
      print('Blink request sent successfully');
    } else {
      print('Failed to send blink request');
    }
  }

  Future<void> _wavePattern() async {
    final response = await http.get(Uri.parse('http://192.168.4.1/move?pattern=wave'));

    if (response.statusCode == 200) {
      print('Wave pattern request sent successfully');
    } else {
      print('Failed to send wave pattern request');
    }
  }

  Future<void> _setIntensity(double intensity) async {
    setState(() {
      _intensity = intensity;
    });

    final response = await http.get(Uri.parse('http://192.168.4.1/move?intensity=$intensity'));

    if (response.statusCode == 200) {
      print('Intensity set successfully');
    } else {
      print('Failed to set intensity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSwitch('Red', _isRedOn, Icons.circle, Colors.red, (value) => _toggleSwitch('red', value)),
                _buildSwitch('Blue', _isBlueOn, Icons.circle, Colors.blue, (value) => _toggleSwitch('blue', value)),
                _buildSwitch('Yellow', _isYellowOn, Icons.circle, Colors.yellow, (value) => _toggleSwitch('yellow', value)),
                _buildSwitch('Green', _isGreenOn, Icons.circle, Colors.green, (value) => _toggleSwitch('green', value)),
                const SizedBox(height: 20),
                _buildSwitch('All Lights', _allLightsOn, Icons.lightbulb_outline, Colors.orange, (value) => _toggleAllLights(value)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _blinkLights,
                  child: const Text('Blink Lights'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _wavePattern,
                  child: const Text('Wave Pattern'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Intensity:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _intensity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: _intensity.toString(),
                      onChanged: (value) => _setIntensity(value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, IconData icon, Color color, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 10),
              Text(
                '$label Switch is ${value ? 'ON' : 'OFF'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: WeatherScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: (val) {
          setState(() {
            _isDarkMode = val;
          });
        },
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const WeatherScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  String _displayResult = 'Enter a city to get its weather.';
  bool _isLoading = false;

  String _getWeatherEmoji(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("clear")) return "☀️";
    if (condition.contains("cloud")) return "☁️";
    if (condition.contains("rain")) return "🌧️";
    if (condition.contains("thunder")) return "⛈️";
    if (condition.contains("snow")) return "❄️";
    if (condition.contains("mist") || condition.contains("fog")) return "🌫️";
    return "🌍"; // default
  }

  Future<void> _getWeather() async {
    final cityName = _cityController.text;
    if (cityName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=b9fb47f6ce48dd0879e9241a86569b60&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final condition = data['weather'][0]['description'];
        final emoji = _getWeatherEmoji(condition);

        setState(() {
          _displayResult =
              '$emoji ${data['name']}\n'
              '🌡 Temp: ${data['main']['temp']}°C\n'
              '☁️ Condition: ${data['weather'][0]['description']}\n'
              ' Feels Like: ${data['main']['feels_like']}°C\n'
              '💨 Wind Speed: ${data['wind']['speed']} m/s\n'
              '⏰ Timezone: ${data['timezone']}';
        });
      } else {
        setState(() {
          _displayResult = '⚠️ Error: Could not find weather for this city.';
        });
      }
    } catch (e) {
      setState(() {
        _displayResult = '❌ Failed to connect. Check your internet.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌤️ Easy Weather'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(value: widget.isDarkMode, onChanged: widget.onThemeToggle),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getWeather,
              icon: const Icon(Icons.cloud_outlined),
              label: const Text('Get Weather'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _displayResult,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, height: 1.5),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/custom_http_client.dart'; // Your custom HTTP client

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _name;
  String? _email;
  String? _userId;
  bool _isLoading = false;
  final CustomHttpClient httpClient = CustomHttpClient();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _fetchUserDetails();
  }

  Future<void> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await httpClient.get('/user/get-user');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _name = data['user']['name'];
          _email = data['user']['email'];
          _userId = data['user']['_id'];
          _isLoading = false;
        });
      } else if (data['authStatus'] == false) {
        logout(context);
      } else {
        _showSnackbar(data['authStatus']);
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WellMom'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting and User Details
                      Text(
                        'Welcome, $_name!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _email ?? 'Email not available',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Metric Cards in Grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildMetricCard(
                              icon: Icons.thermostat,
                              title: 'Temperature',
                              value: '36.5°C',
                              gradientColors: [
                                Colors.red.shade300,
                                Colors.red.shade100,
                              ],
                            ),
                            _buildMetricCard(
                              icon: Icons.favorite,
                              title: 'Blood Pressure',
                              value: '120/80 mmHg',
                              gradientColors: [
                                Colors.pink.shade300,
                                Colors.pink.shade100,
                              ],
                            ),
                            _buildMetricCard(
                              icon: Icons.timeline,
                              title: 'Pulse Rate',
                              value: '72 BPM',
                              gradientColors: [
                                Colors.purple.shade300,
                                Colors.purple.shade100,
                              ],
                            ),
                            _buildMetricCard(
                              icon: Icons.directions_walk,
                              title: 'Body Movement',
                              value: 'Normal',
                              gradientColors: [
                                Colors.blue.shade300,
                                Colors.blue.shade100,
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradientColors,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

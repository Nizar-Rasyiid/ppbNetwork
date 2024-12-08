import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: EarthquakeList(),
    debugShowCheckedModeBanner: false,
  ));
}

class EarthquakeList extends StatefulWidget {
  const EarthquakeList({super.key});

  @override
  _EarthquakeListState createState() => _EarthquakeListState();
}

class _EarthquakeListState extends State<EarthquakeList> {
  List earthquakes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchEarthquakeData();
  }

  Future<void> fetchEarthquakeData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final url =
          'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson'
          '&starttime=${yesterday.toIso8601String()}'
          '&endtime=${today.toIso8601String()}'
          '&limit=10';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          earthquakes = data['features'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load earthquake data');
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake List'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : earthquakes.isEmpty
                  ? const Center(child: Text('No earthquake data available'))
                  : ListView.builder(
                      itemCount: earthquakes.length,
                      itemBuilder: (context, index) {
                        final properties = earthquakes[index]['properties'];
                        final place = properties['place'] ?? 'Unknown Location';
                        final magnitude = properties['mag'] ?? 'Unknown';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Text(
                                magnitude.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(place),
                            subtitle: Text('Magnitude: $magnitude'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Tambahkan navigasi ke halaman detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EarthquakeDetail(
                                    properties: properties,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

class EarthquakeDetail extends StatelessWidget {
  final Map properties;

  const EarthquakeDetail({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    final place = properties['place'] ?? 'Unknown Location';
    final magnitude = properties['mag'] ?? 'Unknown';
    final time = DateTime.fromMillisecondsSinceEpoch(properties['time']);
    final formattedTime = '${time.toLocal()}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: $place', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Magnitude: $magnitude', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Time: $formattedTime', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

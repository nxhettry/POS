import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/endpoints.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? data;
  bool loading = false;

  Future<void> fetchUser() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await ApiService().get(Endpoints.profile);
      setState(() {
        data = response.toString();
      });
    } catch (e) {
      setState(() {
        data = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: fetchUser,
                    child: const Text('Fetch User'),
                  ),
                  if (data != null) ...[
                    const SizedBox(height: 20),
                    Text(data!),
                  ]
                ],
              ),
      ),
    );
  }
}

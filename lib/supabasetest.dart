import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  String _status = "Press the button to test connection";
  bool _isLoading = false;

  Future<void> testConnection() async {
    setState(() {
      _isLoading = true;
      _status = "Connecting...";
    });

    try {
      // Attempt to fetch one row from our test table
      final data = await supabase.from('Villagers').select().limit(1);

      setState(() {
        if (data.isNotEmpty) {
          _status = "Connection Successful: ${data[0]['VillagerName']}";
        } else {
          _status = "Connected, but the table is empty!";
        }
      });
    } catch (e) {
      setState(() {
        _status = "Connection Failed: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supabase Connection Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: testConnection,
                  child: const Text("Run Connection Test")
              ),
            ],
          ),
        ),
      ),
    );
  }
}

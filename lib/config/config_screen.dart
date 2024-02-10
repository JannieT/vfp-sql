import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sales_importer/shared/locator.dart';
import 'package:sales_importer/shared/services/settings_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        actions: _toolbelt,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          minLines: 20,
          maxLines: 30,
        ),
      ),
    );
  }

  List<Widget> get _toolbelt {
    return [
      IconButton(
        icon: const Icon(Icons.save),
        onPressed: () async {
          final service = locator<SettingsService>();
          late Map<String, dynamic> fresh;
          try {
            fresh = jsonDecode(_controller.text);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Oops! Could not save that.'),
              ),
            );
            return;
          }
          await service.saveSettings(fresh);
        },
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final service = locator<SettingsService>();
      final text = await service.settingsRendered();
      setState(() {
        _controller.text = text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

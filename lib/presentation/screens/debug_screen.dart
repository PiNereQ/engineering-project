import 'package:flutter/material.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug'),),
      body: Column(
        children: [
        ],
      )
    );
    
  }
}
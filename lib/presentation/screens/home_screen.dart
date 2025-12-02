import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(
                "Hej!\nTo jest ekran główny.",
                style: TextStyle(fontFamily: 'Itim', fontSize: 36),
                textAlign: TextAlign.start,
              ),
              _PlaceholderContainer(),
              _PlaceholderContainer(),
              _PlaceholderContainer(),
              _PlaceholderContainer(),
              _PlaceholderContainer(),
              _PlaceholderContainer(),
              SizedBox(height: 66), // padding for navbar
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderContainer extends StatelessWidget {
  const _PlaceholderContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.textPrimary, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black, offset: const Offset(2, 2)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/search_dropdown_field.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        backgroundColor: Colors.yellow[200],
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Szerokość framea to max 800 lub cała dostępna szerokość minus padding
          double maxWidth = constraints.maxWidth < 800 ? constraints.maxWidth : 800;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: maxWidth,
                height: 758,
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0xFF000000),
                      blurRadius: 0,
                      offset: Offset(4, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

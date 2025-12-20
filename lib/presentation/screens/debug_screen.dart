import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/rating_popup.dart';


class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String? _authToken;
  bool _isUsed = false;

  @override
  void initState() {
    super.initState();
    _getAuthToken();
  }

  Future<void> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (mounted) {
        setState(() {
          _authToken = token;
        });
      }
      // Print to console
      print('Auth Token: $token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug'),),
      body: SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auth Token:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _authToken ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(formatReduction(20, true)),
            Text(formatReduction(20.1 , true)),
            Text(formatReduction(20, false)),
            Text(formatReduction(20.1, false)),
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'DEBUG – Rating flow',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: _isUsed,
              onChanged: _isUsed
                  ? null
                  : (_) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(width: 2, color: AppColors.textPrimary),
                        ),
                        title: const Text(
                          'Oznaczyć kupon jako wykorzystany?',
                          style: TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        content: const Text(
                          'Po oznaczeniu kuponu jako wykorzystany musisz wystawić ocenę transakcji.',
                          style: TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        actionsPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        actions: [
                          CustomTextButton.small(
                            label: 'Anuluj',
                            width: 100,
                            onTap: () => Navigator.pop(context, false),
                          ),
                          CustomTextButton.primarySmall(
                            label: 'Dalej',
                            width: 100,
                            onTap: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                      if (confirm != true) return;

                      final rated = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => RatingDialog(
                          onCancel: () => Navigator.pop(context, false),
                          onSubmit: (stars, comment) {
                            print('⭐ Rating: $stars');
                            print('💬 Comment: $comment');
                            Navigator.pop(context, true);
                          },
                        ),
                      );

                      if (rated == true && mounted) {
                        setState(() {
                          _isUsed = true;
                        });
                      }
                    },
            ),
            const SizedBox(width: 12),
            const Text(
              'kupon wykorzystany',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),

        if (_isUsed)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Kupon oznaczony jako wykorzystany',
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    ),
  ),
),          
               
          
          ],
          
        ),
      )
      
    );
    
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:proj_inz/presentation/widgets/simple_button.dart';
import 'package:proj_inz/presentation/widgets/ticket_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column (
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                //mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        'icons/Awatar.svg',
                        width: 100,
                        height: 100,
                      ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Cześć, username', 
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w600,
                      ),
                  ),
                ],
            ),
            const SizedBox(height: 8),
            const TicketButton(
              height: 58,
              width: 480,
              leftText: 'Twoje punkty',
              rightText: '997',
              fontSize: 14,
            ),
            const SizedBox(height: 8),
            const Text(
              'Reputacja',
              style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w700,
                      ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Twoje kupony',
              style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w700,
                      ),
              ),
            const SizedBox(height: 8),
            Row(
                //mainAxisSize: MainAxisSize.min,
                children: [
                  SimpleButton(height: 40, width: 130, fontSize: 14, label: 'Kupione', isSelected: false, onTap: () {}),
                  const SizedBox(width: 24),            
                  SimpleButton(height: 40, width: 130, fontSize: 14, label: 'Wystawione', isSelected: false, onTap: () {})
                ],
              ),
            const SizedBox(height: 8),
            SimpleButton(height: 40, width: 480, fontSize: 14, label: 'Obserwowane', isSelected: false, onTap: () {}),
            const SizedBox(height: 16),
            const Text(
              'Twoje preferencje',
              style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w700,
                      ),
              ),
              const SizedBox(height: 8),
            SimpleButton(height: 40, width: 480, fontSize: 14, label: 'Ulubione', isSelected: false, onTap: () {}),
            const SizedBox(height: 16),
            const Text(
              'Ranking',
              style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w700,
                      ),
              ),
            const SizedBox(height: 8),
            const TicketButton(
              height: 58,
              width: 480,
              leftText: 'Twoja pozycja',
              rightText: '3. miejsce',
              fontSize: 14,
            ),
            const SizedBox(height: 8),
            SimpleButton(height: 40, width: 480, fontSize: 14, label: 'Ustawienia', isSelected: false, onTap: () {}),
          ],
        ),
      ),
    );
  }
}
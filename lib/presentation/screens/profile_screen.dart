import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/debug_screen.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/ticket_button.dart';
import 'package:provider/provider.dart';





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
                        'assets/icons/Awatar.svg',
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
                  CustomTextButton(height: 40, width: 130, label: 'Kupione', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BoughtCouponListScreen(), 
                      ),
                    );
                  }),
                  const SizedBox(width: 24),            
                  CustomTextButton(height: 40, width: 130, label: 'Wystawione', onTap: () {})
                ],
              ),
            const SizedBox(height: 8),
            CustomTextButton(height: 40, width: 480, label: 'Obserwowane', onTap: () {}),
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
            Row(
              children: [
                CustomTextButton(height: 40, width: 480, label: 'Ulubione', onTap: () {}),
                CustomTextButton(height: 40, width: 480, label: 'Wyloguj', onTap: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                }),
              ],
            ),
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
            CustomTextButton(height: 40, width: 480, label: 'Ustawienia', onTap: () {}),
            const SizedBox(height: 16),
            if (kDebugMode) CustomTextButton(
              label: 'Debug',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugScreen(),
                  ),
                );
              }
            )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/debug_screen.dart';
import 'package:proj_inz/presentation/screens/sign_in_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/ticket_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          showCustomSnackBar(context, "Wylogowano pomyślnie");

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
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
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 20,
                  children: [
                    Expanded(
                      child: CustomTextButton(
                          label: 'Kupione',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BoughtCouponListScreen(),
                              ),
                            );
                          }),
                    ),
                    Expanded(
                        child: CustomTextButton(
                            label: 'Wystawione', onTap: () {}))
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextButton(
                    width: double.infinity,
                    label: 'Obserwowane',
                    onTap: () {}),
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
                CustomTextButton(
                    width: double.infinity, label: 'Ulubione', onTap: () {}),
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
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 20,
                  children: [
                    Expanded(
                      child: CustomTextButton(
                        label: 'Ustawienia',
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: CustomTextButton(
                        label: 'Wyloguj',
                        backgroundColor: const Color(0xFFFF9A9A),
                        onTap: () {
                          context.read<AuthBloc>().add(SignOutRequested());
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (kDebugMode)
                  CustomTextButton(
                      width: double.infinity,
                      label: 'Debug',
                      icon: const Icon(Icons.developer_mode_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DebugScreen(),
                          ),
                        );
                      })
              ],
            ),
          ),
        );
      },
    );
  }
}
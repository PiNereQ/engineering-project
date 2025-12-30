import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/data/repositories/wallet_repository.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/debug_screen.dart';
import 'package:proj_inz/presentation/screens/listed_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/saved_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/settings_screen.dart';
import 'package:proj_inz/presentation/screens/sign_in_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/reputation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

  class _ProfileScreenState extends State<ProfileScreen> {
    late Future<Map<String, dynamic>?> _profileFuture;

    int? walletBalance;
    bool isLoadingWallet = true;

    late final WalletRepository _walletRepository;

    @override
    void initState() {
      super.initState();
      _walletRepository = WalletRepository();

      final userRepo = context.read<UserRepository>();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      _profileFuture = userRepo.getUserProfile(userId);
      _loadWalletBalance();
    }


    Future<void> _loadWalletBalance() async {
      try {
        final balance = await _walletRepository.getWalletBalance();
        setState(() {
          walletBalance = balance;
          isLoadingWallet = false;
        });
      } catch (_) {
        setState(() {
          walletBalance = 0;
          isLoadingWallet = false;
        });
      }
    }


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
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Row(
                  spacing: 12,
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
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            'Cześć!',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Text(
                            'Cześć!',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }

                        final username = snapshot.data!['username'];

                        return Text(
                          'Cześć, ${username ?? ''}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Reputacja
                Column(
                  spacing: 16,
                  children: [
                    const Row(
                      spacing: 12,
                      children: [
                        Icon(Icons.speed_rounded, size: 28),
                        Text(
                          'Reputacja',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData) {
                          return const Text(
                            'Nie udało się załadować reputacji',
                            style: TextStyle(color: AppColors.alertText),
                          );
                        }

                        final int? reputation = snapshot.data!['reputation'];

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: reputation == null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Brak ocen',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16,
                                        fontFamily: 'Itim',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Reputacja pojawi się, gdy otrzymasz więcej niż 3 oceny transakcji',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontFamily: 'Itim',
                                      ),
                                    ),
                                  ],
                                )
                              : ReputationBar(
                                  value: reputation,
                                ),
                        );
                      },
                    ),
                  ],
                ),
                  // Portfel
                    Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          spacing: 12,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 28),
                            Text(
                              'Portfel',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Itim',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 2, color: AppColors.textPrimary),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: AppColors.textPrimary,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: isLoadingWallet
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Saldo',
                                      style: TextStyle(
                                        fontFamily: 'Itim',
                                        fontSize: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${formatPrice(walletBalance ?? 0)} zł',
                                      style: const TextStyle(
                                        fontFamily: 'Itim',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Środki testowe - brak możliwości wypłaty',
                                      style: TextStyle(
                                        fontFamily: 'Itim',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                // Twoje kupony
                Column(
                  spacing: 16,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 12,
                      children: [
                        Icon(Icons.confirmation_number_outlined, size: 28),
                        Text(
                          'Twoje kupony',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          child: CustomTextButton(
                            label: 'Kupione',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const BoughtCouponListScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: CustomTextButton(
                            label: 'Wystawione',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ListedCouponListScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    CustomTextButton(
                      width: double.infinity,
                      label: 'Zapisane',
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => 
                              const SavedCouponListScreen()
                          )
                        );
                      },
                    ),
                  ],
                ),
                // Preferencje
                Column(
                  spacing: 16,
                  children: [
                    const Row(
                      spacing: 12,
                      children: [
                        Icon(Icons.favorite_outline_rounded, size: 28),
                        Text(
                          'Twoje preferencje',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    CustomTextButton(
                      width: double.infinity,
                      label: 'Ulubione',
                      onTap: () {},
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: DashedSeparator(),
                ),

                Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: CustomTextButton(
                        label: 'Ustawienia',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomTextButton(
                        label: 'Wyloguj',
                        backgroundColor: AppColors.alertButton,
                        onTap: () {
                          context.read<AuthBloc>().add(SignOutRequested());
                        },
                      ),
                    ),
                  ],
                ),

                if (kDebugMode)
                  CustomTextButton(
                    width: double.infinity,
                    label: 'Debug',
                    icon: const Icon(Icons.developer_mode_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DebugScreen(),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}
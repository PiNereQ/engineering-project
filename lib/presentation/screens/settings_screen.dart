import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/number_verification/number_verification_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/screens/phone_number_confirmation_screen.dart';
import 'package:proj_inz/presentation/screens/legal_document_screen.dart';
import 'package:proj_inz/presentation/screens/sign_in_screen.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_switch.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/widgets/input/text_fields/labeled_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _profileFuture = context.read<UserRepository>().getUserProfile(user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // back
              Row(
                children: [
                  CustomIconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const _SectionTitle(
                text: 'Konto',
                icon: Icons.person_outline,
              ),

              FutureBuilder<Map<String, dynamic>?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Text(
                      'Nie udało się załadować danych użytkownika',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        color: AppColors.alertText,
                      ),
                    );
                  }

                  final user = snapshot.data!;
                  final bool hasPhoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber?.isNotEmpty ?? false;
                  if (kDebugMode) print(FirebaseAuth.instance.currentUser?.phoneNumber);

                  return _SectionCard(
                    child: Column(
                      spacing: 12,
                      children: [
                        _KeyValueRow(
                          label: 'Nazwa użytkownika',
                          value: user['username'] ?? '—',
                        ),
                        _KeyValueRow(
                          label: 'Adres e-mail',
                          value: user['email'] ?? '—',
                        ),
                        _KeyValueRow(
                          label: 'Data dołączenia',
                          value: user['join_date'] != null
                              ? user['join_date'].toString().substring(0, 10)
                              : '—',
                        ),
                        _KeyValueRow(
                          label: 'Numer telefonu',
                          value: hasPhoneNumber ? 'Potwierdzony' : 'Niepotwierdzony',
                          trailing: !hasPhoneNumber
                              ? CustomTextButton.small(
                                  label: 'Potwierdź',
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider<NumberVerificationBloc>.value(
                                          value: context.read<NumberVerificationBloc>()
                                            ..add(NumberVerificationFormShownAfterRegistration()),
                                          child: const PhoneNumberConfirmationScreen(),
                                        ),
                                      ),
                                    );
                                    _fetchProfile();
                                  },
                                )
                              : null,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: DashedSeparator(),
                        ),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(label: 'Kupionych kuponów', value: '0'),
                            _StatItem(label: 'Sprzedanych kuponów', value: '0'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // powiadomienia
              const _SectionTitle(
                text: 'Powiadomienia',
                icon: Icons.notifications_none,
              ),
              _SectionCard(
                child: Column(
                  children: [
                    const _SwitchRow(label: 'Wiadomości (Czat)'),
                    const _SwitchRow(label: 'Zmiana statusu kuponu'),
                    const _SwitchRow(label: 'Kupony rekomendowane'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // blokady
              const _SectionTitle(
                text: 'Zablokowani użytkownicy',
                icon: Icons.block_rounded,
              ),

              _SectionCard(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: context.read<UserRepository>()
                      .getBlockedUsers(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text(
                        'Nie masz zablokowanych użytkowników.',
                        style: TextStyle(
                          fontFamily: 'Itim',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      );
                    }

                    final blocked = snapshot.data!;

                    return Column(
                      spacing: 12,
                      children: blocked.map((u) {
                        final userId = u['id'] as String;
                        final username = u['username'] as String? ?? 'Użytkownik';

                        return _BlockedUserRow(
                          username: username,
                          onUnblock: () async {
                            final confirmed = await showUnblockConfirmDialog(
                              context,
                              username,
                            );

                            if (confirmed != true) return;

                            await context.read<UserRepository>().unblockUser(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              blockedUserId: userId,
                            );

                            if (!context.mounted) return;
                            setState(() {});
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // dokumenty
              const _SectionTitle(
                text: 'Dokumenty',
                icon: Icons.description_outlined,
              ),
              _SectionCard(
                child: Column(
                  children: [
                    _NavRow(label: 'Regulamin',   onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalDocumentScreen(
                          title: 'Regulamin',
                          assetPath: 'assets/legal/regulamin.md',
                        ),
                      ),
                    ),),
                    _NavRow(label: 'Polityka prywatności', onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalDocumentScreen(
                          title: 'Polityka prywatności',
                          assetPath: 'assets/legal/polityka_prywatnosci.md',
                        ),
                      ),
                    ),),
                    _NavRow(label: 'Dokumentacja użytkownika', onTap: () {  },),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // usun konto
              Center(
                child: CustomTextButton(
                  label: 'Usuń konto',
                  backgroundColor: AppColors.alertButton,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const _DeleteAccountDialog(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SectionTitle({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.textPrimary,
          ),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 24,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
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
      child: child,
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _KeyValueRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Itim',
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Itim',
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

  class _SwitchRow extends StatefulWidget {
    final String label;
    const _SwitchRow({required this.label});

    @override
    State<_SwitchRow> createState() => _SwitchRowState();
  }

  class _SwitchRowState extends State<_SwitchRow> {
    bool value = true;

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 18,
              ),
            ),
            CustomSwitch(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ],
        ),
      );
    }
  }

class _NavRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavRow({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Itim',
          fontSize: 18,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(width: 2, color: AppColors.textPrimary),
      ),
      title: const Text(
        'Usunąć konto?',
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 22,
          color: AppColors.textPrimary,
        ),
      ),
      content: const Text(
        'Ta operacja jest nieodwracalna. Twoje konto zostanie dezaktywowane.',
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        CustomTextButton.small(
          label: 'Anuluj',
          width: 100,
          onTap: () => Navigator.pop(context),
        ),
        CustomTextButton.primarySmall(
          label: 'Usuń',
          width: 100,
          onTap: () {
            Navigator.pop(context);

            showDialog(
              context: context,
              builder: (_) => const _ConfirmDeleteWithPasswordDialog(),
            );
          },
        ),
      ],
    );
  }
}

class _ConfirmDeleteWithPasswordDialog extends StatefulWidget {
  const _ConfirmDeleteWithPasswordDialog();

  @override
  State<_ConfirmDeleteWithPasswordDialog> createState() =>
      _ConfirmDeleteWithPasswordDialogState();
}

class _ConfirmDeleteWithPasswordDialogState
    extends State<_ConfirmDeleteWithPasswordDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _confirmDelete() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email!;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: _passwordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      await context.read<UserRepository>().disableAccount(user.uid);

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SignInScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (_) {
      setState(() {
        _error = 'Nieprawidłowe hasło';
      });
    } catch (_) {
      setState(() {
        _error = 'Nie udało się usunąć konta';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: AppColors.textPrimary),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.textPrimary,
              blurRadius: 0,
              offset: Offset(4, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Potwierdź usunięcie konta',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Wpisz hasło, aby potwierdzić usunięcie konta.\n'
              'Ta operacja jest nieodwracalna.',
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            LabeledTextField(
              label: 'Hasło',
              controller: _passwordController,
              isPassword: true,
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.alertText,
                  fontSize: 14,
                  fontFamily: 'Itim',
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: CustomTextButton.small(
                    label: 'Anuluj',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextButton.primarySmall(
                    label: _isLoading ? '...' : 'Usuń konto',
                    onTap: () {
                      if (_isLoading) return;
                      _confirmDelete();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedUserRow extends StatelessWidget {
  final String username;
  final VoidCallback onUnblock;

  const _BlockedUserRow({
    required this.username,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            username,
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        CustomTextButton.small(
          label: 'Odblokuj',
          onTap: onUnblock,
        ),
      ],
    );
  }
}

Future<bool?> showUnblockConfirmDialog(
  BuildContext context,
  String username,
) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(width: 2, color: AppColors.textPrimary),
      ),
      title: const Text(
        'Odblokować użytkownika?',
        style: TextStyle(
          fontFamily: 'Itim',
          fontSize: 22,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Użytkownik $username będzie mógł ponownie wysyłać do Ciebie wiadomości.',
        style: const TextStyle(
          fontFamily: 'Itim',
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        CustomTextButton.small(
          label: 'Anuluj',
          onTap: () => Navigator.pop(context, false),
        ),
        CustomTextButton.primarySmall(
          label: 'Odblokuj',
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
}
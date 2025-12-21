import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_switch.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _profileFuture =
        context.read<UserRepository>().getUserProfile(user.uid);
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
                          value: user['joinDate'] != null
                              ? user['joinDate'].toString().substring(0, 10)
                              : '—',
                        ),
                        const _KeyValueRow(
                          label: 'Numer telefonu',
                          value: 'Niepotwierdzony',
                          trailing: _InlineAction(text: 'Potwierdź'),
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
                text: 'Blokady',
                icon: Icons.block_rounded,
              ),
              _SectionCard(
                child: const Text(
                  'Nie masz zablokowanych użytkowników.',
                  style: TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
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
                    _NavRow(label: 'Regulamin', onTap: () {  },),
                    _NavRow(label: 'Polityka prywatności', onTap: () {  },),
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

class _InlineAction extends StatelessWidget {
  final String text;
  const _InlineAction({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Itim',
        fontSize: 16,
        color: AppColors.primaryButton,
      ),
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
            // TODO backend
          },
        ),
      ],
    );
  }
}

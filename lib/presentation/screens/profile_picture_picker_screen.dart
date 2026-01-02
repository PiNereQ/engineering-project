import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class ProfilePicturePickerScreen extends StatefulWidget {
  final int currentAvatarId;

  const ProfilePicturePickerScreen({
    super.key,
    required this.currentAvatarId,
  });

  @override
  State<ProfilePicturePickerScreen> createState() =>
      _ProfilePicturePickerScreenState();
}

class _ProfilePicturePickerScreenState
    extends State<ProfilePicturePickerScreen> {
  late int selectedAvatarId;
  bool isSaving = false;

  final avatars = List.generate(5, (i) => i);

  @override
  void initState() {
    super.initState();
    selectedAvatarId = widget.currentAvatarId;
  }

  Future<void> _save() async {
    setState(() => isSaving = true);

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final repo = context.read<UserRepository>();

    try {
      await repo.changeProfilePicture(
        userId: userId,
        profilePictureId: selectedAvatarId,
      );

      if (!mounted) return;

      showCustomSnackBar(context, 'Zmieniono zdjęcie profilowe');
      Navigator.pop(context, selectedAvatarId);
    } catch (_) {
      showCustomSnackBar(context, 'Nie udało się zmienić zdjęcia');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wybierz avatar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: avatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final id = avatars[index];
                  final isSelected = id == selectedAvatarId;

                  return GestureDetector(
                    onTap: () => setState(() => selectedAvatarId = id),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryButton
                              : AppColors.textPrimary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/avatars/avatar_$id.png'),
                      ),
                    ),
                  );
                },
              ),
            ),
            CustomTextButton.primary(
              label: isSaving ? 'Zapisywanie...' : 'Zapisz',
              onTap: () {
                if (isSaving) return;
                _save();
              },
            ),
          ],
        ),
      ),
    );
  }
}
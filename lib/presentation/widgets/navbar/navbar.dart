import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/bloc/navbar/navbar_bloc.dart';
import 'package:proj_inz/bloc/navbar/navbar_event.dart';
import 'package:proj_inz/bloc/navbar/navbar_state.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_state.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_event.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/navbar/navbar_item.dart';
import 'package:proj_inz/presentation/screens/add_screen.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavbarBloc, NavbarState>(
      builder: (context, navState) {
        return BlocBuilder<ChatUnreadBloc, ChatUnreadState>(
          builder: (context, chatState) {
            final hasUnread = chatState.hasUnread;

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.textPrimary, width: 2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.textPrimary,
                    blurRadius: 0,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NavbarItem(
                      label: "Dla Ciebie",
                      icon: Icons.home_outlined,
                      isSelected: navState.selectedIndex == 0,
                      hasBadge: false,
                      onTap: () =>
                          context.read<NavbarBloc>().add(NavbarItemSelected(0)),
                    ),
                    NavbarItem(
                      label: "Kupony",
                      icon: Icons.card_giftcard_outlined,
                      isSelected: navState.selectedIndex == 1,
                      hasBadge: false,
                      onTap: () =>
                          context.read<NavbarBloc>().add(NavbarItemSelected(1)),
                    ),
                    NavbarItem(
                      label: "Dodaj",
                      icon: Icons.add_box_outlined,
                      isSelected: navState.selectedIndex == 2,
                      hasBadge: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddScreen(),
                        ),
                      ),
                    ),
                    NavbarItem(
                      label: "Czat",
                      icon: Icons.chat_outlined,
                      isSelected: navState.selectedIndex == 3,
                      hasBadge: hasUnread,
                      onTap: () {
                        context.read<NavbarBloc>().add(NavbarItemSelected(3));
                        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                        context.read<ChatUnreadBloc>().add(CheckUnreadStatus(userId: userId));
                      },
                    ),
                    NavbarItem(
                      label: "Profil",
                      icon: Icons.account_circle_outlined,
                      isSelected: navState.selectedIndex == 4,
                      hasBadge: false,
                      onTap: () =>
                          context.read<NavbarBloc>().add(NavbarItemSelected(4)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
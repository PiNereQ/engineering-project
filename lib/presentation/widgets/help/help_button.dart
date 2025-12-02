import 'package:flutter/material.dart';
import 'package:proj_inz/presentation/widgets/help/help_popup.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';

class HelpButton extends StatelessWidget {
  final String title;
  final Widget body;
  const HelpButton({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      icon: const Icon(Icons.help_outline_rounded),
      onTap: () {
      showDialog(
        context: context,
        builder: (context) => Center(child: SingleChildScrollView(child: HelpPopup(body: body, title: title))),
      );
      },
    );
  }
}

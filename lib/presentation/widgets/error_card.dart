import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class ErrorCard extends StatelessWidget {

  final Widget icon;
  final String text;
  final String errorString;
  
  const ErrorCard({
    super.key,
    required this.icon,
    required this.text,
    required this.errorString
  });

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFF000000),
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: icon,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                  maxLines: null,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextButton.iconSmall(
            label: 'Kopiuj komunikat błędu',
            icon: const Icon(Icons.copy_rounded),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: errorString));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Skopiowano komunikat do schowka'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          CustomTextButton.iconSmall(
            label: 'Zgłoś problem',
            icon: const Icon(Icons.send_rounded),
            onTap: () {}, // TODO: reporting
          ),
        ],
      ),
    );
  }
}
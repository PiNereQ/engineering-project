import 'package:flutter/material.dart';

enum CustomComponentWidth { full, half }

class SearchDropdownField extends StatefulWidget {
  final List<String> options;
  final String? selected;
  final String? placeholder;
  final Function(String?) onChanged;
  final CustomComponentWidth widthType;
  final FormFieldValidator<String?>? validator;

  const SearchDropdownField({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.placeholder,
    this.widthType = CustomComponentWidth.full,
    this.validator
  });

  @override
  State<SearchDropdownField> createState() => _SearchDropdownFieldState();
}

class _SearchDropdownFieldState extends State<SearchDropdownField> {
  late String? currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double desiredWidth = constraints.maxWidth;
        if (widget.widthType == CustomComponentWidth.half) {
          desiredWidth = (desiredWidth - 16) / 2;
        }

        return SizedBox(
          width: desiredWidth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0xFF000000),
                  blurRadius: 0,
                  offset: Offset(4, 4),
                  spreadRadius: 0,
                )
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                initialValue: currentValue,
                hint: widget.placeholder != null
                    ? Text(
                        widget.placeholder!,
                        style: const TextStyle(
                          color: Color(0xFF646464),
                          fontSize: 18,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : null,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(
                  color: Color(0xFF646464),
                  fontSize: 18,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                ),
                dropdownColor: Colors.white,
                items: widget.options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    currentValue = newValue;
                  });
                  widget.onChanged(newValue);
                },
                validator: widget.validator,
              ),
            ),
          ),
        );
      },
    );
  }
}

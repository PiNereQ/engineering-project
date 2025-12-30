import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class CustomCalendarDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomCalendarDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomCalendarDatePickerDialog> createState() =>
      _CustomCalendarDatePickerDialogState();
}

class _CustomCalendarDatePickerDialogState
    extends State<CustomCalendarDatePickerDialog> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
    });
  }

  bool _isDisabled(DateTime day) {
    return day.isBefore(widget.firstDate) ||
        day.isAfter(widget.lastDate);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  List<DateTime> _buildDaysGrid() {
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);

    final firstWeekday = firstDayOfMonth.weekday;
    final startOffset = firstWeekday - 1;

    final startDay =
        firstDayOfMonth.subtract(Duration(days: startOffset));

    return List.generate(42, (index) {
      return startDay.add(Duration(days: index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildDaysGrid();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(width: 2, color: AppColors.textPrimary),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // headerr
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  _monthLabel(_displayedMonth),
                  style: const TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // weekdays
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _Weekday('Pn'),
                _Weekday('Wt'),
                _Weekday('Śr'),
                _Weekday('Cz'),
                _Weekday('Pt'),
                _Weekday('Sb'),
                _Weekday('Nd'),
              ],
            ),

            const SizedBox(height: 8),

            // days grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth =
                    day.month == _displayedMonth.month;
                final isSelected = _isSameDay(day, _selectedDate);
                final isDisabled = _isDisabled(day);

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () {
                          setState(() {
                            _selectedDate = day;

                            if (!isCurrentMonth) {
                              _displayedMonth = DateTime(day.year, day.month);
                            }
                          });
                        },
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isSelected ? 36 : 32,
                      height: isSelected ? 36 : 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primaryButton
                            : Colors.transparent,
                        border: _isSameDay(day, _today)
                            ? Border.all(
                                width: 2,
                                color: AppColors.primaryButton,
                              )
                            : null,
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: AppColors.textPrimary,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontFamily: 'Itim',
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isDisabled || !isCurrentMonth
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : isSelected
                                  ? AppColors.surface
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomTextButton.small(
                  label: 'Anuluj',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                CustomTextButton.primarySmall(
                  label: 'Zapisz',
                  onTap: () =>
                      Navigator.of(context).pop(_selectedDate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Styczeń',
      'Luty',
      'Marzec',
      'Kwiecień',
      'Maj',
      'Czerwiec',
      'Lipiec',
      'Sierpień',
      'Wrzesień',
      'Październik',
      'Listopad',
      'Grudzień',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _Weekday extends StatelessWidget {
  final String label;

  const _Weekday(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Itim',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
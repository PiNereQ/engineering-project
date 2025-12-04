import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class ReportScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUsername;
  final int reportedUserReputation;
  final DateTime reportedUserJoinDate;

  final Coupon? reportedCoupon;

  const ReportScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUsername,
    required this.reportedUserReputation,
    required this.reportedUserJoinDate,
    this.reportedCoupon,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? selectedReason;
  final TextEditingController descriptionController = TextEditingController();
  bool showMissingReasonTip = false;

  @override
  Widget build(BuildContext context) {
    final isCouponReport = widget.reportedCoupon != null;

    final reasons = isCouponReport
        ? [
            "Kod kuponu jest nieprawidłowy",
            "Termin ważności kuponu minął",
            "Kupon ma ograniczenia, których nie było w opisie",
            "Zdjęcie kuponu jest nieczytelne",
            "Nieodpowiednia nazwa użytkownika sprzedającego",
            "Nieodpowiedni obraz profilu sprzedającego",
            "Inne",
          ]
        : [
            "Spam",
            "Próba oszustwa",
            "Nękanie, groźby lub obraza",
            "Nieodpowiednie treści",
            "Nieodpowiednia nazwa użytkownika",
            "Nieodpowiedni obraz profilu",
            "Inne",
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomIconButton(
                      icon: SvgPicture.asset('assets/icons/back.svg'),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // user tile
              _UserTile(
                username: widget.reportedUsername,
                reputation: widget.reportedUserReputation,
                joinDate: widget.reportedUserJoinDate,
              ),

              const SizedBox(height: 16),

              // coupon tile)
              if (widget.reportedCoupon != null) ...[
                _CouponTile(coupon: widget.reportedCoupon!),
                const SizedBox(height: 24),
              ],

              // reasons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(width: 2, color: AppColors.textPrimary),
                  ),
                  shadows: const [
                    BoxShadow(color: AppColors.textPrimary, offset: Offset(4, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Wybierz powód zgłoszenia",
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Użytkownik nie dowie się o twoim zgłoszeniu",
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...reasons.map((reason) {
                      final selected = selectedReason == reason;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _WrappingRadioButton(
                          label: reason,
                          selected: selected,
                          onTap: () => setState(() => selectedReason = reason),
                        ),
                      );
                    }).toList(),
                    if (showMissingReasonTip)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Wybierz powód zgłoszenia.",
                          style: TextStyle(
                            color: AppColors.alertText,
                            fontSize: 14,
                            fontFamily: 'Itim',
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // description
              _DescriptionBox(controller: descriptionController),

              const SizedBox(height: 32),

              // send
              Center(
                child: CustomTextButton.primary(
                  label: "Wyślij zgłoszenie",
                  icon: const Icon(Icons.send, color: AppColors.textPrimary, size: 20),
                  width: 220,
                  height: 56,
                  onTap: () {
                    FocusScope.of(context).unfocus();

                    if (selectedReason == null) {
                      setState(() {
                        showMissingReasonTip = true;
                      });
                      return;
                    }

                    // TODO backend
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  final Coupon coupon;

  const _CouponTile({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dotyczy kuponu:",
          style: TextStyle(
            fontFamily: 'Itim',
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        CouponCardHorizontal(coupon: coupon),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  final String username;
  final int reputation;
  final DateTime joinDate;

  const _UserTile({
    required this.username,
    required this.reputation,
    required this.joinDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(width: 2, color: AppColors.textPrimary),
        ),
        shadows: const [
          BoxShadow(color: AppColors.textPrimary, offset: Offset(4,4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Text(
            "Dotyczy użytkownika:",
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),

          Row(
            children: [
              const CircleAvatar(radius: 30),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildReputationBar(reputation),
                    const SizedBox(height: 4),
                    Text(
                      "Na Coupidynie od ${joinDate.day}.${joinDate.month}.${joinDate.year}",
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReputationBar(int value) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey.shade300,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.green,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("$value"),
      ],
    );
  }
}

class _ReasonSelector extends StatelessWidget {
  final String title;
  final List<String> reasons;
  final String? selected;
  final ValueChanged<String> onChanged;

  const _ReasonSelector({
    required this.title,
    required this.reasons,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Użytkownik nie dowie się o twoim zgłoszeniu",
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          ...reasons.map((r) {
            return RadioListTile<String>(
              title: Text(
                r,
                style: const TextStyle(
                    fontFamily: 'Itim', fontSize: 16, color: AppColors.textPrimary),
              ),
              value: r,
              groupValue: selected,
              onChanged: (v) => onChanged(r),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  final TextEditingController controller;

  const _DescriptionBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(width: 2, color: AppColors.textPrimary),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Opis problemu (opcjonalny)",
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: controller,
            maxLines: 6,
            minLines: 4,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: "Opisz problem...",
              hintStyle: TextStyle(
                fontFamily: 'Itim',
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _WrappingRadioButton extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _WrappingRadioButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // radio
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 4),
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(100),
                ),
                shadows: const [
                  BoxShadow(
                    color: AppColors.textPrimary,
                    blurRadius: 0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.checkIcon,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                softWrap: true,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontFamily: 'Itim',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
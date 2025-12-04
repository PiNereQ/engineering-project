import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/radio_button.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Zgłoszenie",
          style: TextStyle(fontFamily: 'Itim', color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // user tile
            _UserTile(
              username: widget.reportedUsername,
              reputation: widget.reportedUserReputation,
              joinDate: widget.reportedUserJoinDate,
            ),

            const SizedBox(height: 16),

            // coupon tile
            if (widget.reportedCoupon != null)
              _CouponTile(coupon: widget.reportedCoupon!),

            const SizedBox(height: 24),

            // reasons for reporting
            Container(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(width: 2, color: AppColors.textPrimary),
                ),
                shadows: const [
                  BoxShadow(
                    color: AppColors.textPrimary,
                    offset: Offset(4,4),
                  ),
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
                      child: CustomRadioButton(
                        label: reason,
                        selected: selected,
                        onTap: () => setState(() => selectedReason = reason),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // description
            _DescriptionBox(controller: descriptionController),

            const SizedBox(height: 32),

            // send button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                ),
                onPressed: () {
                  // TODO backend
                  Navigator.pop(context);
                },
                child: const Text(
                  "Wyślij zgłoszenie  ➤",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Itim',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
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
        spacing: 12,
        children: [
          const Text(
            "Dotyczy kuponu:",
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),

          CouponCardHorizontal(coupon: coupon),

        ],
      ),
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
      padding: const EdgeInsets.all(16),
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

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textPrimary, width: 1),
            ),
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Opisz problem...",
                hintStyle: TextStyle(
                  fontFamily: 'Itim',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

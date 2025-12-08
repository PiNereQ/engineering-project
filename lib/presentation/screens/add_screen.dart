import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/coupon_add/coupon_add_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/text_formatters.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/bloc/shop/shop_bloc.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/help/help_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import '../widgets/input/text_fields/labeled_text_field.dart';
import '../widgets/input/search_dropdown_field.dart';
import '../widgets/input/buttons/checkbox.dart';
import '../widgets/input/buttons/radio_button.dart';
import '../widgets/input/buttons/custom_text_button.dart';

enum CouponType { percent, fixed }

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  // Controllers for text fields
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _reductionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _expiryDate;
  Shop? _selectedShop;
  CouponType _selectedType = CouponType.percent;
  bool _hasExpiryDate = true;
  bool _inPhysicalStores = false;
  bool _inOnlineStore = false;
  bool _hasRestrictions = false; // null = brak wyboru, true = tak, false = nie

  bool _userMadeInput = false;
  bool _showMissingValuesTip = false;
  bool _showUsageLocationTip = false;

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _priceController.dispose();
    _expiryDateController.dispose();
    _codeController.dispose();
    _reductionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    backDialog() {
      return showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(width: 2, color: AppColors.textPrimary),
              ),
              title: const Text(
                'Potwierdzenie',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              content: const Text(
                'Czy na pewno chcesz opuścić ekran dodawania kuponu? Wprowadzone dane zostaną utracone.',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                CustomTextButton.small(
                  label: 'Anuluj',
                  width: 100,
                  onTap: () => Navigator.of(context).pop(),
                ),
                CustomTextButton.primarySmall(
                  label: 'Tak',
                  width: 100,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CouponAddBloc(context.read<CouponRepository>()),
        ),
        BlocProvider(
          create:
              (context) =>
                  ShopBloc(context.read<ShopRepository>())..add(LoadShops()),
        ),
      ],
      child: BlocListener<CouponAddBloc, CouponAddState>(
        listener: (context, state) {
          if (state is CouponAddSuccess) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        width: 2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    title: const Text(
                      'Sukces',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    content: const Text(
                      'Kupon został dodany.',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    actionsPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    actions: [
                      CustomTextButton.primarySmall(
                        label: 'OK',
                        width: 100,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
            );
          } else if (state is CouponAddFailure) {
            _focusScopeNode.unfocus();
            showCustomSnackBar(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth =
                    constraints.maxWidth < 800 ? constraints.maxWidth : 800;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomIconButton(
                                icon: SvgPicture.asset('assets/icons/back.svg'),
                                onTap: () {
                                  if (_userMadeInput) {
                                    backDialog();
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                              HelpButton(title: "Pomoc - Dodawanie kuponu", body: _HelpBody())
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: maxWidth,
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 2,
                                color: AppColors.textPrimary,
                              ),
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
                          child: FocusScope(
                            node: _focusScopeNode,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 1. Tytul
                                        const SizedBox(
                                          width: 332,
                                          child: Text(
                                            'Dodaj kupon',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 24,
                                              fontFamily: 'Itim',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        // 2. Wybierz sklep (search dropdown) TODO: Lista sklepow z bazy
                                        BlocBuilder<ShopBloc, ShopState>(
                                          builder: (context, state) {
                                            if (state is ShopLoading) {
                                              return const CircularProgressIndicator();
                                            } else if (state is ShopLoaded) {
                                              return SearchDropdownField(
                                                options:
                                                    state.shops
                                                        .map((s) => s.name)
                                                        .toList(),
                                                selected: _selectedShop?.name,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _selectedShop = state.shops
                                                        .firstWhere(
                                                          (s) => s.name == val,
                                                        );
                                                    _userMadeInput = true;
                                                  });
                                                },
                                                widthType:
                                                    CustomComponentWidth.full,
                                                placeholder: 'Wybierz sklep',
                                                validator: (val) {
                                                  if (val == null ||
                                                      val.isEmpty) {
                                                    return 'Wymagane';
                                                  }
                                                  return null;
                                                },
                                              );
                                            } else {
                                              return const Text(
                                                "Błąd podczas ładowania sklepów.",
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        // 3. Cena i Data waznosci
                                        Wrap(
                                          spacing: 16,
                                          runSpacing: 16,
                                          children: [
                                            LabeledTextField(
                                              label: 'Cena',
                                              placeholder: 'Wpisz cenę',
                                              width: LabeledTextFieldWidth.half,
                                              iconOnLeft: true,
                                              controller: _priceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                PriceFormatter()
                                              ],
                                              suffix: Text('zł'),
                                              validator: (val) {
                                                if (val == null || val.isEmpty) {
                                                  return 'Wymagane';
                                                }
                                                if (double.tryParse(val) ==
                                                    null) {
                                                  return 'Niepoprawna liczba';
                                                }
                                                // Check for at most 2 decimal places (grosze)
                                                final parts = val.replaceAll(',', '.').split('.');
                                                if (parts.length > 1 && parts[1].length > 2) {
                                                  return 'Cena może mieć maksymalnie 2 miejsca po przecinku';
                                                }
                                                if (double.tryParse(val)! <= 0) {
                                                  return 'Wpisz więcej niż 0';
                                                }
                                                return null;
                                              },
                                              onChanged: (val) {
                                                setState(() {
                                                  _userMadeInput = true;
                                                });
                                              },
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                DateTime now = DateTime.now();
                                                DateTime today = DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                );

                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate: today,
                                                      firstDate: today,
                                                      lastDate: DateTime(2100),
                                                    );
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    _expiryDateController.text =
                                                        "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                                    _expiryDate = pickedDate;
                                                    _userMadeInput = true;
                                                  });
                                                }
                                              },
                                              child: AbsorbPointer(
                                                child: LabeledTextField(
                                                  label: 'Data ważności',
                                                  placeholder: 'DD-MM-RRRR',
                                                  width:
                                                      LabeledTextFieldWidth
                                                          .half,
                                                  iconOnLeft: false,
                                                  controller:
                                                      _expiryDateController,
                                                  keyboardType:
                                                      TextInputType.datetime,
                                                  validator: (val) {
                                                    if (val == null ||
                                                        val.isEmpty && _hasExpiryDate) {
                                                      return 'Wymagane';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        CustomCheckbox(
                                          label: 'Kupon nie ma daty ważności',
                                          selected: !_hasExpiryDate,
                                          onTap: () {
                                            setState(() {
                                              _hasExpiryDate = !_hasExpiryDate;
                                              _userMadeInput = true;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 18),

                                        // 4. Kod kuponu
                                        LabeledTextField(
                                          label: 'Kod kuponu',
                                          placeholder: 'Wpisz kod kuponu',
                                          width: LabeledTextFieldWidth.full,
                                          iconOnLeft: true,
                                          controller: _codeController,
                                          onChanged: (val) {
                                            setState(() {
                                              _userMadeInput = true;
                                            });
                                          },
                                          validator: (val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Wymagane';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),

                                        // 5. Info i przycisk "Dodaj zdjecie"
                                        Center(
                                          child: CustomTextButton.primary(
                                            height: 52,
                                            width: 160,
                                            label: 'Dodaj zdjęcie',
                                            onTap: () {
                                              debugPrint(
                                                'Kliknięto: Dodaj zdjęcie',
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.priority_high_rounded,
                                              size: 24,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Text(
                                                'Jeśli Twój kupon nie posiada kodu w formie tekstu (ale ma kod kreskowy, QR itp.), możesz go zeskanować dodając zdjęcie.',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 14,
                                                  fontFamily: 'Itim',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),

                                        // 6. Typ kuponu (radiobuttony) - stan zmienia textfield, TODO: bloc event
                                        const Text(
                                          'Typ kuponu',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 18,
                                            fontFamily: 'Itim',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomRadioButton(
                                                    label: 'rabat -%',
                                                    selected:
                                                        _selectedType ==
                                                        CouponType.percent,
                                                    onTap: () {
                                                      setState(() {
                                                        _reductionController.text = '';
                                                        _selectedType =
                                                            CouponType.percent;
                                                        _userMadeInput = true;
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 12),
                                                  CustomRadioButton(
                                                    label: 'rabat -zł',
                                                    selected:
                                                        _selectedType ==
                                                        CouponType.fixed,
                                                    onTap: () {
                                                      setState(() {
                                                        _reductionController.text = '';
                                                        _selectedType =
                                                            CouponType.fixed;
                                                        _userMadeInput = true;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              flex: 1,
                                              child:
                                                  _selectedType ==
                                                          CouponType.percent
                                                      ? LabeledTextField(
                                                        label: 'Procent rabatu',
                                                        width:
                                                            LabeledTextFieldWidth
                                                                .full,
                                                        textAlign:
                                                            TextAlign.right,
                                                        controller:
                                                            _reductionController,
                                                        inputFormatters: [
                                                          PercentFormatter()
                                                        ],
                                                        suffix: Text('%'),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            _userMadeInput =
                                                                true;
                                                          });
                                                        },
                                                        validator: (val) {
                                                          if (val == null ||
                                                              val.isEmpty) {
                                                            return 'Wymagane';
                                                          }
                                                          if (double.tryParse(
                                                                val,
                                                              ) ==
                                                              null) {
                                                            return 'Niepoprawna liczba';
                                                          }
                                                          if (double.tryParse(
                                                                val,
                                                              )! <=
                                                              0) {
                                                            return 'Wpisz więcej niż 0';
                                                          }
                                                          if (double.tryParse(
                                                                val,
                                                              )! >
                                                              100) {
                                                            return 'Wpisz conajwyżej 100';
                                                          }
                                                          return null;
                                                        },
                                                      )
                                                      : LabeledTextField(
                                                        label: 'Kwota rabatu',
                                                        width:
                                                            LabeledTextFieldWidth
                                                                .full,
                                                        textAlign:
                                                            TextAlign.right,
                                                        controller:
                                                            _reductionController,
                                                        inputFormatters: [
                                                          PriceFormatter()
                                                        ],
                                                        suffix: Text('zł'),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (val) {
                                                          setState(() {
                                                            _userMadeInput =
                                                                true;
                                                          });
                                                        },
                                                        validator: (val) {
                                                          if (val == null ||
                                                              val.isEmpty) {
                                                            return 'Wymagane';
                                                          }
                                                          if (double.tryParse(
                                                                val,
                                                              ) ==
                                                              null) {
                                                            return 'Niepoprawna liczba';
                                                          }
                                                          if (double.tryParse(
                                                                val,
                                                              )! <=
                                                              0) {
                                                            return 'Wpisz więcej niż 0';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                            ),
                                          ],
                                        ),

                                        // 7. Do wykorzystania w... (checkboxy)
                                        const SizedBox(height: 24),
                                        const Text(
                                          'Do wykorzystania w:',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 18,
                                            fontFamily: 'Itim',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomCheckbox(
                                              label: 'w sklepach stacjonarnych',
                                              selected: _inPhysicalStores,
                                              onTap: () {
                                                setState(() {
                                                  _inPhysicalStores =
                                                      !_inPhysicalStores;
                                                  _userMadeInput = true;
                                                });
                                                setState(() {
                                                  _showUsageLocationTip =
                                                      _inPhysicalStores ==
                                                          false &&
                                                      _inOnlineStore == false;
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 12),
                                            CustomCheckbox(
                                              label: 'w sklepie internetowym',
                                              selected: _inOnlineStore,
                                              onTap: () {
                                                setState(() {
                                                  _inOnlineStore =
                                                      !_inOnlineStore;
                                                  _userMadeInput = true;
                                                });
                                                setState(() {
                                                  _showUsageLocationTip =
                                                      _inPhysicalStores ==
                                                          false &&
                                                      _inOnlineStore == false;
                                                });
                                              },
                                            ),
                                          ],
                                        ),

                                        if (_showUsageLocationTip)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Zaznacz przynajmniej jedną opcję.',
                                              style: TextStyle(
                                                color: AppColors.alertText,
                                                fontSize: 14,
                                                fontFamily: 'Itim',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),

                                        const SizedBox(height: 24),

                                        // 8. Czy kupon ma ograniczenia (radiobuttony)
                                        const Text(
                                          'Czy Twój kupon ma ograniczenia?',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 18,
                                            fontFamily: 'Itim',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 20,
                                          children: [
                                            CustomRadioButton(
                                              label: 'tak',
                                              selected:
                                                  _hasRestrictions == true,
                                              onTap: () {
                                                setState(() {
                                                  _hasRestrictions = true;
                                                  _userMadeInput = true;
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 12),
                                            CustomRadioButton(
                                              label: 'nie',
                                              selected:
                                                  _hasRestrictions == false,
                                              onTap: () {
                                                setState(() {
                                                  _hasRestrictions = false;
                                                  _userMadeInput = true;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.priority_high_rounded,
                                              size: 24,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Text(
                                                'Jeśli Twój kupon posiada ograniczenia tj. wyłączone produkty/kategorie z promocji - wypisz je w opisie!',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 14,
                                                  fontFamily: 'Itim',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),

                                        // 9. opis
                                        LabeledTextField(
                                          label: 'Opis',
                                          placeholder:
                                              'Np. kupon nie obejmuje produktów z kategorii Elektronika...',
                                          width: LabeledTextFieldWidth.full,
                                          maxLines: 6,
                                          textAlign: TextAlign.left,
                                          controller: _descriptionController,
                                          onChanged: (val) {
                                            setState(() {
                                              _userMadeInput = true;
                                            });
                                          },
                                          validator: (val) {
                                              if (val == null ||
                                                  val.isEmpty && _hasRestrictions) {
                                                return 'Wpisz opis ograniczeń';
                                              }
                                              return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // separator
                                  DashedSeparator(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 18.0,
                                      left: 24.0,
                                      right: 24.0,
                                      bottom: 24.0,
                                    ),
                                    child: Column(
                                      children: [
                                        if (_showMissingValuesTip) ...[
                                          const Text(
                                            'Uzupełnij brakujące pola, aby móc dodać kupon.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.alertText,
                                              fontSize: 16,
                                              fontFamily: 'Itim',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        // 11. Przycisk dodaj
                                        CustomTextButton.primary(
                                          height: 56,
                                          width: double.infinity,
                                          label: 'Dodaj',
                                          onTap: () async {
                                            FocusScope.of(context).unfocus();

                                            if (_formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              if (!_inPhysicalStores &&
                                                  !_inOnlineStore) {
                                                setState(() {
                                                  _showUsageLocationTip = true;
                                                });
                                                return;
                                              }
                                              // Get current user ID
                                              final userRepo = context.read<UserRepository>();
                                              final user = await userRepo.getCurrentUser();
                                              if (user == null) {
                                                setState(() {
                                                  _showMissingValuesTip = true;
                                                });
                                                return;
                                              }

                                              // Ensure user exists in API database
                                              try {
                                                await userRepo.ensureUserExistsInApi();
                                              } catch (e) {
                                                if (mounted) {
                                                  showCustomSnackBar(context, 'Błąd synchronizacji użytkownika: $e');
                                                }
                                                return;
                                              }

                                              // Format expiry date as YYYY-MM-DD or null
                                              String? expiryDateStr;
                                              if (_hasExpiryDate && _expiryDateController.text.isNotEmpty) {
                                                expiryDateStr = "${_expiryDate.year}-${_expiryDate.month.toString().padLeft(2, '0')}-${_expiryDate.day.toString().padLeft(2, '0')}";
                                              }

                                              // Handle description (nullable if empty)
                                              String? description = _descriptionController.text.trim().isEmpty 
                                                  ? null 
                                                  : _descriptionController.text.trim();

                                              final offer = CouponOffer(
                                                description: description,
                                                discount:
                                                    double.tryParse(
                                                      _reductionController.text,
                                                    ) ??
                                                    0,
                                                isDiscountPercentage:
                                                    _selectedType ==
                                                    CouponType.percent,
                                                price:
                                                    double.tryParse(
                                                      _priceController.text,
                                                    ) ??
                                                    0,
                                                code: _codeController.text,
                                                hasLimits: _hasRestrictions,
                                                worksOnline: _inOnlineStore,
                                                worksInStore: _inPhysicalStores,
                                                expiryDate: expiryDateStr,
                                                shopId: int.tryParse(_selectedShop?.id ?? '0') ?? 0,
                                                ownerId: user.uid,
                                                isActive: true,
                                              );

                                              final confirmed = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      backgroundColor:
                                                          AppColors.surface,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                        side: const BorderSide(
                                                          width: 2,
                                                          color:
                                                              AppColors
                                                                  .textPrimary,
                                                        ),
                                                      ),
                                                      title: const Text(
                                                        'Potwierdzenie',
                                                        style: TextStyle(
                                                          fontFamily: 'Itim',
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              AppColors
                                                                  .textPrimary,
                                                        ),
                                                      ),
                                                      content: const Text(
                                                        'Czy na pewno chcesz dodać ten kupon?',
                                                        style: TextStyle(
                                                          fontFamily: 'Itim',
                                                          fontSize: 16,
                                                          color:
                                                              AppColors
                                                                  .textSecondary,
                                                        ),
                                                      ),
                                                      actionsPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 12,
                                                          ),
                                                      actions: [
                                                        CustomTextButton.small(
                                                          label: 'Anuluj',
                                                          width: 100,
                                                          onTap:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(false),
                                                        ),
                                                        CustomTextButton.primarySmall(
                                                          label: 'Dodaj',
                                                          width: 100,
                                                          onTap:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(true),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirmed == true) {
                                                context
                                                    .read<CouponAddBloc>()
                                                    .add(AddCouponOffer(offer));
                                              }
                                            } else {
                                              setState(() {
                                                _showMissingValuesTip = true;
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Dodając kupon, akceptujesz postanowienia regulaminu.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontFamily: 'Itim',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpBody extends StatelessWidget {
  const _HelpBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '''1. Wybierz sklep, w którym chcesz dodać kupon.\n
2. Wpisz cenę, za którą chcesz wystawić kupon na sprzedaż.\n
3. Jeżeli kupon ma datę wygaśnięcia - wpisz ją. Niektóre kupony są bezterminowe - jeżeli Twój kupon taki jest, zaznacz\n
4. Wpisz kod kuponu dokładnie tak, jak jest on podany w sklepie (uwzględniając wielkość liter).\n
5. Wybierz typ kuponu - czy jest to rabat procentowy czy na stałą kwotę, a następnie wpisz wartość rabatu.\n
6. Zaznacz, gdzie można wykorzystać kupon - w sklepach stacjonarnych, w sklepie internetowym lub w obu miejscach.\n
7. Określ, czy kupon ma jakieś ograniczenia (np. wyłączone produkty lub kategorie). Jeśli tak, opisz je w polu "Opis".\n
8. Po uzupełnieniu wszystkich wymaganych pól, kliknij przycisk "Dodaj", aby dodać kupon do systemu.''',
        style: TextStyle(fontFamily: 'Itim', fontSize: 18),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
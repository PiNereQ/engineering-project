import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/coupon_add/coupon_add_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/bloc/shop/shop_bloc.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
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
  bool _inPhysicalStores = false;
  bool _inOnlineStore = false;
  bool _hasRestrictions = false; // null = brak wyboru, true = tak, false = nie

  bool _userMadeInput = false;
  bool _showMissingValuesTip = false;

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
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(width: 2, color:AppColors.textPrimary),
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
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          create: (context) =>
              ShopBloc(context.read<ShopRepository>())..add(LoadShops()),
        ),
      ],
      child: BlocListener<CouponAddBloc, CouponAddState>(
        listener: (context, state) {
          if (state is CouponAddSuccess) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(width: 2, color: AppColors.textPrimary),
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
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            CustomIconButton(
                              icon: const Icon(Icons.info_outline_rounded),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16,),
                      Container(
                        width: maxWidth,
                        padding: const EdgeInsets.all(24),
                        decoration: ShapeDecoration(
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 2, color: AppColors.textPrimary),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      options: state.shops.map((s) => s.name).toList(),
                                      selected: _selectedShop?.name,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedShop = state.shops.firstWhere((s) => s.name == val);
                                          _userMadeInput = true;
                                        });
                                      },
                                      widthType: CustomComponentWidth.full,
                                      placeholder: 'Wybierz sklep',
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Wymagane';
                                        return null;
                                      },
                                    );
                                  } else {
                                    return const Text("Błąd podczas ładowania sklepów.");
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
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Wymagane';
                                      if (double.tryParse(val) == null) return 'Niepoprawna liczba';
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
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(DateTime.now().year),
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
                                        width: LabeledTextFieldWidth.half,
                                        iconOnLeft: false,
                                        controller: _expiryDateController,
                                        keyboardType: TextInputType.datetime,
                                        validator: (val) {
                                        if (val == null || val.isEmpty) return 'Wymagane';
                                        return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
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
                                  if (val == null || val.isEmpty) return 'Wymagane';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                          
                              // 5. Info i przycisk "Dodaj zdjecie"
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 72),
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/report-outline-rounded.svg',
                                              height: 24,
                                              width: 24,
                                              colorFilter: const ColorFilter.mode(
                                                AppColors.textSecondary,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Expanded(
                                              child: Text(
                                                'Jeśli Twój kupon nie posiada kodu w formie tekstu, zeskanuj go dodając zdjęcie',
                                                style: TextStyle(
                                                  color: AppColors.textSecondary,
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
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 132),
                                    child: Center(
                                      child: CustomTextButton.primary(
                                        height: 51.86,
                                        width: 160,
                                        label: 'Dodaj zdjęcie',
                                        onTap: () {
                                          debugPrint('Kliknięto: Dodaj zdjęcie');
                                        },
                                      ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomRadioButton(
                                          label: 'rabat -%',
                                          selected:
                                              _selectedType == CouponType.percent,
                                          onTap: () {
                                            setState(() {
                                              _selectedType = CouponType.percent;
                                              _userMadeInput = true;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        CustomRadioButton(
                                          label: 'rabat -zł',
                                          selected: _selectedType == CouponType.fixed,
                                          onTap: () {
                                            setState(() {
                                              _selectedType = CouponType.fixed;
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
                                    child: _selectedType == CouponType.percent
                                        ? LabeledTextField(
                                            label: 'Procent rabatu',
                                            placeholder: '%',
                                            width: LabeledTextFieldWidth.full,
                                            textAlign: TextAlign.right,
                                            controller: _reductionController,
                                            keyboardType: TextInputType.number,
                                            onChanged: (val) {
                                              setState(() {
                                                _userMadeInput = true;
                                              });
                                            },
                                            validator: (val) {
                                              if (val == null || val.isEmpty) return 'Wymagane';
                                              if (double.tryParse(val) == null) return 'Niepoprawna liczba';
                                              return null;
                                              },
                                          )
                                        : LabeledTextField(
                                            label: 'Kwota rabatu',
                                            placeholder: 'zł',
                                            width: LabeledTextFieldWidth.full,
                                            textAlign: TextAlign.right,
                                            controller: _reductionController,
                                            keyboardType: TextInputType.number,
                                            onChanged: (val) {
                                              setState(() {
                                                _userMadeInput = true;
                                              });
                                            },
                                            validator: (val) {
                                              if (val == null || val.isEmpty) return 'Wymagane';
                                              if (double.tryParse(val) == null) return 'Niepoprawna liczba';
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomCheckbox(
                                    label: 'w sklepach stacjonarnych',
                                    selected: _inPhysicalStores,
                                    onTap: () {
                                      setState(() {
                                        _inPhysicalStores = !_inPhysicalStores;
                                        _userMadeInput = true;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  CustomCheckbox(
                                    label: 'w sklepie internetowym',
                                    selected: _inOnlineStore,
                                    onTap: () {
                                      setState(() {
                                        _inOnlineStore = !_inOnlineStore;
                                        _userMadeInput = true;
                                      });
                                    },
                                  ),
                                ],
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
                              const SizedBox(height: 12),
                          
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // radiobuttony
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomRadioButton(
                                          label: 'tak',
                                          selected: _hasRestrictions == true,
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
                                          selected: _hasRestrictions == false,
                                          onTap: () {
                                            setState(() {
                                              _hasRestrictions = false;
                                              _userMadeInput = true;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                          
                                  const SizedBox(width: 20),
                          
                                  // informacja
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                              'assets/icons/report-outline-rounded.svg',
                                            height: 24,
                                            width: 24,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.textSecondary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Jeśli Twój kupon posiada ograniczenia tj. wyłączone produkty/kategorie z promocji - wypisz je w opisie',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
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
                              ),
                              const SizedBox(height: 24),
                          
                              // separator
                              SizedBox(
                                width: double.infinity,
                                child: SvgPicture.asset(
                                  'assets/icons/separator_wide.svg',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              const SizedBox(height: 18),
                          
                              // 10. Liczba punktow za dodanie kuponow TODO: liczenie punktow
                              const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Za dodanie tego kuponu dostaniesz',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontFamily: 'Itim',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '100 pkt',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontFamily: 'Itim',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          
                              const SizedBox(height: 18),

                              if (_showMissingValuesTip)
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
                              const SizedBox(height: 8),
                              // 11. Przycisk dodaj
                              CustomTextButton.primary(
                                height: 56,
                                width: double.infinity,
                                label: 'Dodaj',
                                onTap: () async {
                                  FocusScope.of(context).unfocus();

                                  if (_formKey.currentState?.validate() ?? false) {
                                    final offer = CouponOffer(
                                      description: _descriptionController.text,
                                      reduction:
                                          double.tryParse(_reductionController.text) ??
                                              0,
                                      reductionIsPercentage:
                                          _selectedType == CouponType.percent,
                                      price:
                                          double.tryParse(_priceController.text) ?? 0,
                                      code: _codeController.text,
                                      hasLimits: _hasRestrictions,
                                      worksOnline: _inOnlineStore,
                                      worksInStore: _inPhysicalStores,
                                      expiryDate: _expiryDate,
                                      shopId: _selectedShop?.id ?? '',
                                    );

                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: AppColors.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          side: const BorderSide(
                                            width: 2,
                                            color: AppColors.textPrimary,
                                          ),
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
                                          'Czy na pewno chcesz dodać ten kupon?',
                                          style: TextStyle(
                                            fontFamily: 'Itim',
                                            fontSize: 16,
                                            color: AppColors.textSecondary,
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
                                            onTap: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                          ),
                                          CustomTextButton.primarySmall(
                                            label: 'Dodaj',
                                            width: 100,
                                            onTap: () =>
                                                Navigator.of(context)
                                                    .pop(true),
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
                              const SizedBox(height: 18),
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

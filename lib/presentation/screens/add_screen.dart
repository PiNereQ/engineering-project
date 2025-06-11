import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/coupon_add/coupon_add_bloc.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
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

  // Controllers for text fields
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _reductionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _expiryDate;
  String? _selectedShop;
  CouponType _selectedType = CouponType.percent;
  bool _inPhysicalStores = false;
  bool _inOnlineStore = false;
  bool _hasRestrictions = false; // null = brak wyboru, true = tak, false = nie

  @override
  void dispose() {
    _priceController.dispose();
    _expiryDateController.dispose();
    _codeController.dispose();
    _reductionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _backDialog() {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(width: 2, color: Colors.black),
          ),
          title: const Text(
            'Potwierdzenie',
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Czy na pewno chcesz opuścić ekran dodawania kuponu? Wprowadzone dane zostaną utracone.',
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 16,
              color: Color(0xFF646464),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            CustomTextButton.small(
              label: 'Anuluj',
              width: 100,
              onTap: () => Navigator.of(context).pop(),
            ),
            CustomTextButton.small(
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

    return BlocProvider(
      create: (context) => CouponAddBloc(context.read<CouponRepository>()),
      child: Scaffold(
        backgroundColor: Colors.yellow[200],
        body: LayoutBuilder(
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
                            icon: SvgPicture.asset('icons/back.svg'),
                            onTap: () => _backDialog(),
                          ),
                          CustomIconButton(
                            icon: const Icon(Icons.info),
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
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontFamily: 'Itim',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                        
                            // 2. Wybierz sklep (search dropdown) TODO: Lista sklepow z bazy
                              SearchDropdownField(
                              options: [
                                '0'
                              ],
                              selected: _selectedShop,
                              onChanged: (val) {
                                setState(() {
                                _selectedShop = val ?? '';
                                });
                              },
                              widthType: CustomComponentWidth.full,
                              placeholder: 'Wybierz sklep',
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Wymagane';
                                return null;
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
                                ),
                                GestureDetector(
                                  onTap: () async {
                                  FocusScope.of(context).unfocus();
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
                                            'icons/report-outline-rounded.svg',
                                            height: 24,
                                            width: 24,
                                            colorFilter: const ColorFilter.mode(
                                              Color(0xFF646464),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Jeśli Twój kupon nie posiada kodu w formie tekstu, zeskanuj go dodając zdjęcie',
                                              style: TextStyle(
                                                color: Color(0xFF646464),
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
                                    child: CustomTextButton(
                                      height: 51.86,
                                      width: 160,
                                      fontSize: 18,
                                      label: 'Dodaj zdjęcie',
                                      onTap: () {
                                        print('Kliknięto: Dodaj zdjęcie');
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
                                color: Colors.black,
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
                                color: Colors.black,
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
                                color: Colors.black,
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
                                          'icons/report-outline-rounded.svg',
                                          height: 24,
                                          width: 24,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF646464),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Jeśli Twój kupon posiada ograniczenia tj. wyłączone produkty/kategorie z promocji - wypisz je w opisie',
                                            style: TextStyle(
                                              color: Color(0xFF646464),
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
                            ),
                            const SizedBox(height: 24),
                        
                            // separator
                            SizedBox(
                              width: double.infinity,
                              child: SvgPicture.asset(
                                'icons/separator_wide.svg',
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
                                      color: Colors.black,
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
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        
                            const SizedBox(height: 18),
                        
                            // 11. Przycisk dodaj
                            CustomTextButton(
                              height: 56,
                              width: double.infinity,
                              fontSize: 20,
                              label: 'Dodaj',
                              onTap: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  print('Kliknięto Dodaj');
                                  final offer = CouponOffer(
                                    description: _descriptionController.text,
                                    reduction: double.tryParse(_reductionController.text) ?? 0,
                                    reductionIsPercentage: _selectedType == CouponType.percent,
                                    price: double.tryParse(_priceController.text) ?? 0,
                                    code: _codeController.text,
                                    hasLimits: _hasRestrictions,
                                    worksOnline: _inOnlineStore,
                                    worksInStore: _inPhysicalStores,
                                    expiryDate: _expiryDate,
                                    shopId: _selectedShop.toString(),
                                  );
                                  context.read<CouponAddBloc>().add(AddCouponOffer(offer));
                                } else {
                                  print('Formularz nie jest kompletny!');
                                }
                              },
                            ),
                            const SizedBox(height: 18),
                          ],
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
    );
  }
}

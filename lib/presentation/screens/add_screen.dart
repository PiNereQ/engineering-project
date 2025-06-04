import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  CouponType _selectedType = CouponType.percent;

  bool _inPhysicalStores = false;
  bool _inOnlineStore = false;
  bool? _hasRestrictions; // null = brak wyboru, true = tak, false = nie

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        backgroundColor: Colors.yellow[200],
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth < 800 ? constraints.maxWidth : 800;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: maxWidth,
                height: 758,
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
                child: SingleChildScrollView(
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
                        options: ['Mediamarkt', 'Zooplus', 'Żabka', 'Auchan', 'Rossmann'],
                        selected: null,
                        onChanged: (val) => print('Sklep: $val'),
                        widthType: CustomComponentWidth.full,
                        placeholder: 'Wybierz sklep',
                      ),
                      const SizedBox(height: 18),

                      // 3. Cena i Data waznosci TODO: walidacje
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: const [
                          LabeledTextField(
                            label: 'Cena',
                            placeholder: 'Wpisz cenę',
                            width: LabeledTextFieldWidth.half,
                            iconOnLeft: true,
                          ),
                          LabeledTextField(
                            label: 'Data ważności',
                            placeholder: 'DD-MM-RRRR',
                            width: LabeledTextFieldWidth.half,
                            iconOnLeft: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 4. Kod kuponu
                      const LabeledTextField(
                        label: 'Kod kuponu',
                        placeholder: 'Wpisz kod kuponu',
                        width: LabeledTextFieldWidth.full,
                        iconOnLeft: true,
                      ),
                      const SizedBox(height: 18),

                      // 5. Info i przycisk "Dodaj zdjecie"
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 72),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                  selected: _selectedType == CouponType.percent,
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
                                ? const LabeledTextField(
                                    label: 'Procent rabatu',
                                    placeholder: '%',
                                    width: LabeledTextFieldWidth.full,
                                    textAlign: TextAlign.right,
                                  )
                                : const LabeledTextField(
                                    label: 'Kwota rabatu',
                                    placeholder: 'zł',
                                    width: LabeledTextFieldWidth.full,
                                    textAlign: TextAlign.right,
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
                      const LabeledTextField(
                        label: 'Opis',
                        placeholder: 'Np. kupon nie obejmuje produktów z kategorii Elektronika...',
                        width: LabeledTextFieldWidth.full,
                        maxLines: 6,
                        textAlign: TextAlign.left,
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
                      Row(
                          children: const [
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
                          print('Kliknięto Dodaj');
                        },
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

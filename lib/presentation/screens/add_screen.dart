import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/search_dropdown_field.dart';
import '../widgets/checkbox.dart';
import '../widgets/radiobutton.dart';
import '../widgets/simple_button.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

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

                      // 2. Wybierz sklep (search dropdown)
                      SearchDropdownField(
                        options: ['Mediamarkt', 'Zooplus', 'Żabka', 'Auchan', 'Rossmann'],
                        selected: null,
                        onChanged: (val) => print('Sklep: $val'),
                        widthType: CustomComponentWidth.full,
                        placeholder: 'Wybierz sklep',
                      ),
                      const SizedBox(height: 18),

                      // 3. Cena i Data waznosci
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

                      // 5. Informacja i przycisk "Dodaj zdjecie"
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // wysrodkowanie buttona wzgledem calego wiersza
                        children: [
                          // Tekst i ikona - rozszerzalne
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
                                    Expanded(
                                      child: Text(
                                        'Jeśli Twój kupon nie posiada kodu w formie tekstu, zeskanuj go dodając zdjęcie',
                                        style: const TextStyle(
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

                          // Przycisk "Dodaj zdjecie"
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 132),
                            child: Center(
                              child: SimpleButton(
                                height: 51.86,
                                width: 160,
                                fontSize: 18,
                                label: 'Dodaj zdjęcie',
                                isSelected: false,
                                onTap: () {
                                  print('Kliknięto: Dodaj zdjęcie');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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

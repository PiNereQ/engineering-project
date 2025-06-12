import 'package:flutter/material.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_bloc.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dodajemy AppBar z paddingiem
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // wyłącz domyślne back button
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Mały przycisk z ikoną strzałki wstecz
              InkWell(
                borderRadius: BorderRadius.circular(1000),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0xFF000000),
                        blurRadius: 0,
                        offset: Offset(3, 3),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, size: 16, color: Colors.black),
                ),
              ),
              const SizedBox(width: 16),
              // Search bar z tekstem "Wyniki dla hasła: <query>"
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  clipBehavior: Clip.antiAlias,
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
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Wyniki dla hasła: $query',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          // --- Usuwamy poprzedni search bar z body, bo mamy go już w AppBar ---

          // Dalej lista wyników - zajmuje resztę ekranu
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchLoaded) {
                  final results = state.results;
                  if (results.isEmpty) {
                    return const Center(child: Text('Brak wyników'));
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final shopColor = Color(item.bgColor);

                      return Container(
                        width: double.infinity,
                        height: 65,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        clipBehavior: Clip.antiAlias,
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
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 45,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: shopColor,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(minHeight: 36),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/coupons',
                                        arguments: {'shopId': item.id, 'name': item.name},
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(1000),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(width: 2),
                                          borderRadius: BorderRadius.circular(1000),
                                        ),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0xFF000000),
                                            blurRadius: 0,
                                            offset: Offset(3, 3),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: const Text(
                                        'Pokaż kupony',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 36,
                                  height: 36,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 2),
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0xFF000000),
                                        blurRadius: 0,
                                        offset: Offset(2, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'icons/favorite.svg',
                                      width: 18,
                                      height: 18
                                    )
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is SearchError) {
                  return Center(child: Text('Błąd: ${state.message}'));
                }
                return const Center(child: Text('Wpisz zapytanie'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

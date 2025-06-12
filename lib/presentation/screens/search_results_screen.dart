import 'package:flutter/material.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_bloc.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_event.dart';
import 'package:proj_inz/bloc/search_shops_categories/search_shops_categories_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wyniki dla: $query')),
      body: BlocBuilder<SearchBloc, SearchState>(
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
                return ListTile(
                  title: Text(item.name),
                  // inne widgety z danymi elementu
                );
              },
            );
          } else if (state is SearchError) {
            return Center(child: Text('Błąd: ${state.message}'));
          }
          return const Center(child: Text('Wpisz zapytanie'));
        },
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_products_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchProductsUseCase searchProductsUseCase;

  SearchBloc({required this.searchProductsUseCase}) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await searchProductsUseCase(query);
      if (results.isEmpty) {
        emit(SearchEmpty(query: query));
      } else {
        emit(SearchLoaded(products: results, query: query));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
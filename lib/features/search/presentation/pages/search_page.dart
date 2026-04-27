import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furnimatch/features/product/presentation/pages/product_details_page.dart';
import 'package:furnimatch/features/search/data/datasource/search_remote_datasource.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_product_card.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/usecases/search_products_usecase.dart';

class SearchPage extends StatelessWidget {
  final int? userId;
  final String? userName;

  const SearchPage({super.key, this.userId, this.userName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(
        searchProductsUseCase: SearchProductsUseCase(
          SearchRepositoryImpl(
            SearchRemoteDataSourceImpl(),
          ),
        ),
      ),
      child: _SearchView(userId: userId, userName: userName),
    );
  }
}

class _SearchView extends StatefulWidget {
  final int? userId;
  final String? userName;

  const _SearchView({this.userId, this.userName});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final Color darkBrown = const Color(0xFF7D533D);
  final Color bgColor = const Color(0xFFF6F0E9);
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: darkBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFEFE9E2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (value) {
              context.read<SearchBloc>().add(SearchQueryChanged(value));
            },
            decoration: InputDecoration(
              hintText: "Chair, desk, lamp, etc",
              prefixIcon:
                  const Icon(Icons.search, size: 22, color: Colors.black54),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          size: 20, color: Colors.black45),
                      onPressed: () {
                        _controller.clear();
                        context.read<SearchBloc>().add(SearchCleared());
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search,
                      size: 80, color: darkBrown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "Search for furniture",
                    style: TextStyle(
                        color: darkBrown.withOpacity(0.5), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          if (state is SearchEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 80, color: darkBrown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No results for "${state.query}"',
                    style: TextStyle(
                        color: darkBrown.withOpacity(0.5), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (state is SearchError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          }

          if (state is SearchLoaded) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: GridView.builder(
                itemCount: state.products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return SearchProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(
                            product: {
                              'id': product.id,
                              'name': product.name,
                              'description': product.description,
                              'price': product.price,
                              'category': product.category,
                              'image_url': product.imageUrl,
                              'stock': product.stock,
                              'colors': product.colors,
                              'sale_price': product.salePrice,
                              'store_name': product.storeName,
                            },
                            userId: widget.userId,
                            userName: widget.userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
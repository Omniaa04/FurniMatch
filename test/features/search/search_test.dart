import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/search/domain/entities/search_product.dart';
import 'package:furnimatch/features/search/domain/repositories/search_repository.dart';
import 'package:furnimatch/features/search/domain/usecases/search_products_usecase.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository mockRepository;
  late SearchProductsUseCase searchProductsUseCase;

  setUp(() {
    mockRepository = MockSearchRepository();
    searchProductsUseCase = SearchProductsUseCase(mockRepository);
  });

  group('Search Feature', () {
    test(
      'should return a list of products when searching',
      () async {
        // Arrange
        final products = [
          const SearchProduct(
            id: 1,
            name: 'Modern Chair',
            description: 'Comfortable wooden chair',
            price: 1200,
            category: 'Chair',
            imageUrl: 'chair.png',
            stock: 10,
            colors: ['Brown'],
            salePrice: null,
            storeName: 'Furniture Store',
          ),
        ];

        when(() => mockRepository.searchProducts(any()))
            .thenAnswer((_) async => products);

        // Act
        final result = await searchProductsUseCase('chair');

        // Assert
        expect(result, isA<List<SearchProduct>>());
        expect(result.length, 1);
        expect(result.first.name, 'Modern Chair');
        expect(result.first.category, 'Chair');

        verify(() => mockRepository.searchProducts('chair')).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
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
    test(
  'should return an empty list when no products match the search',
  () async {
    // Arrange
    when(() => mockRepository.searchProducts('table'))
        .thenAnswer((_) async => []);

    // Act
    final result = await searchProductsUseCase('table');

    // Assert
    expect(result, isEmpty);

    verify(() => mockRepository.searchProducts('table')).called(1);
    verifyNoMoreInteractions(mockRepository);
  },
);

test(
  'should throw an exception when repository fails',
  () async {
    // Arrange
    when(() => mockRepository.searchProducts('chair'))
        .thenThrow(Exception('Search failed'));

    // Act & Assert
    expect(
      () => searchProductsUseCase('chair'),
      throwsException,
    );

    verify(() => mockRepository.searchProducts('chair')).called(1);
    verifyNoMoreInteractions(mockRepository);
  },
);

test(
  'should return multiple matching products',
  () async {
    // Arrange
    final products = [
      const SearchProduct(
        id: 1,
        name: 'Modern Chair',
        description: 'Chair',
        price: 1200,
        category: 'Chair',
        imageUrl: 'chair.png',
        stock: 5,
        colors: ['Brown'],
        salePrice: null,
        storeName: 'Store A',
      ),
      const SearchProduct(
        id: 2,
        name: 'Classic Chair',
        description: 'Wooden Chair',
        price: 1500,
        category: 'Chair',
        imageUrl: 'chair2.png',
        stock: 8,
        colors: ['Black'],
        salePrice: 1300,
        storeName: 'Store B',
      ),
    ];

    when(() => mockRepository.searchProducts('chair'))
        .thenAnswer((_) async => products);

    // Act
    final result = await searchProductsUseCase('chair');

    // Assert
    expect(result.length, 2);
    expect(result.first.name, 'Modern Chair');
    expect(result.last.name, 'Classic Chair');

    verify(() => mockRepository.searchProducts('chair')).called(1);
    verifyNoMoreInteractions(mockRepository);
  },
);

test(
  'should return product with correct details',
  () async {
    // Arrange
    const product = SearchProduct(
      id: 10,
      name: 'Luxury Sofa',
      description: 'Large comfortable sofa',
      price: 4500,
      category: 'Sofa',
      imageUrl: 'sofa.png',
      stock: 3,
      colors: ['Gray', 'Blue'],
      salePrice: 3999,
      storeName: 'Luxury Store',
    );

    when(() => mockRepository.searchProducts('sofa'))
        .thenAnswer((_) async => [product]);

    // Act
    final result = await searchProductsUseCase('sofa');

    // Assert
    expect(result.first.id, 10);
    expect(result.first.name, 'Luxury Sofa');
    expect(result.first.price, 4500);
    expect(result.first.salePrice, 3999);
    expect(result.first.stock, 3);
    expect(result.first.colors.length, 2);
    expect(result.first.storeName, 'Luxury Store');

    verify(() => mockRepository.searchProducts('sofa')).called(1);
    verifyNoMoreInteractions(mockRepository);
  },
);
  });
}
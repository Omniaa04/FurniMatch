import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:furnimatch/features/ar/data/datasources/ar_remote_datasource.dart';
import 'package:furnimatch/features/ar/data/repositories/ar_repository_impl.dart';
import 'package:furnimatch/features/ar/domain/entities/ar_model.dart';

class MockArRemoteDataSource extends Mock implements ArRemoteDataSource {}

void main() {
  late MockArRemoteDataSource mockRemoteDataSource;
  late ArRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockArRemoteDataSource();
    repository = ArRepositoryImpl(mockRemoteDataSource);
  });

  group('ArRepositoryImpl', () {
    test(
      'should return ArModel when remote data source succeeds',
      () async {
        // Arrange
        const arModel = ArModel(
          productId: 101,
          glbUrl: 'https://example.com/model.glb',
          usdzUrl: 'https://example.com/model.usdz',
        );

        when(() => mockRemoteDataSource.getArModel(any()))
            .thenAnswer((_) async => arModel);

        // Act
        final result = await repository.getArModel(101);

        // Assert
        expect(result, arModel);

        verify(() => mockRemoteDataSource.getArModel(101)).called(1);

        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should throw Exception when remote data source fails',
      () async {
        // Arrange
        when(() => mockRemoteDataSource.getArModel(any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getArModel(101),
          throwsException,
        );

        verify(() => mockRemoteDataSource.getArModel(101)).called(1);

        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );
  });
}
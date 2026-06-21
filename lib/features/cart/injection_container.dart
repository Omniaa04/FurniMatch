import 'package:get_it/get_it.dart';
import 'data/datasources/cart_local_datasource.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'domain/repositories/cart_repository.dart';
import 'domain/usecases/cart_usecases.dart';
import 'presentation/bloc/cart_bloc.dart';

final sl = GetIt.instance;

void initCartDependencies() {
  // DataSource
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuantityUseCase(sl()));
  sl.registerLazySingleton(() => RemoveItemUseCase(sl()));
  sl.registerLazySingleton(() => GetCartSummaryUseCase(sl()));
  sl.registerLazySingleton(() => ApplyPromoCodeUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => CartBloc(
      getCartItems: sl(),
      updateQuantity: sl(),
      removeItem: sl(),
      getCartSummary: sl(),
      applyPromoCode: sl(),
    ),
  );
}

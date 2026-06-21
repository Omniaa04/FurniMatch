// lib/features/orders/presentation/cubit/orders_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  OrdersLoaded(this.orders);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

class OrderStatusUpdating extends OrdersState {
  final List<OrderEntity> orders;
  OrderStatusUpdating(this.orders);
}

class OrderStatusUpdated extends OrdersState {
  final List<OrderEntity> orders;
  final String message;
  OrderStatusUpdated(this.orders, this.message);
}

class OrderStatusUpdateFailed extends OrdersState {
  final List<OrderEntity> orders;
  final String error;
  OrderStatusUpdateFailed(this.orders, this.error);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class OrdersCubit extends Cubit<OrdersState> {
  final GetCustomerOrdersUseCase getCustomerOrdersUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  List<OrderEntity> _currentOrders = [];

  OrdersCubit({
    required this.getCustomerOrdersUseCase,
    required this.updateOrderStatusUseCase,
  }) : super(OrdersInitial());

  Future<void> loadOrders(int customerId) async {
    emit(OrdersLoading());
    try {
      _currentOrders = await getCustomerOrdersUseCase(customerId);
      emit(OrdersLoaded(List.from(_currentOrders)));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> updateStatus(int orderId, String newStatus, int customerId) async {
    emit(OrderStatusUpdating(List.from(_currentOrders)));
    try {
      await updateOrderStatusUseCase(orderId, newStatus);
      _currentOrders = await getCustomerOrdersUseCase(customerId);
      emit(OrderStatusUpdated(
        List.from(_currentOrders),
        'Order #$orderId updated to $newStatus',
      ));
    } catch (e) {
      emit(OrderStatusUpdateFailed(List.from(_currentOrders), e.toString()));
    }
  }
}
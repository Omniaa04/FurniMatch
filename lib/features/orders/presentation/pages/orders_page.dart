// lib/features/orders/presentation/pages/orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';
import '../cubit/orders_cubit.dart';

class OrdersPage extends StatelessWidget {
  final int customerId; // the logged-in user's id
  const OrdersPage({Key? key, required this.customerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = OrderRemoteDataSourceImpl(client: http.Client());
        final repository = OrderRepositoryImpl(remoteDataSource: dataSource);
        return OrdersCubit(
          getCustomerOrdersUseCase: GetCustomerOrdersUseCase(repository),
          updateOrderStatusUseCase: UpdateOrderStatusUseCase(repository),
        )..loadOrders(customerId);
      },
      child: _OrdersView(customerId: customerId),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _OrdersView extends StatelessWidget {
  final int customerId;
  const _OrdersView({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 0,
        actions: [
          BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) {
              final isLoading =
                  state is OrdersLoading || state is OrderStatusUpdating;
              return isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () =>
                          context.read<OrdersCubit>().loadOrders(customerId),
                    );
            },
          ),
        ],
      ),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state is OrderStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is OrderStatusUpdateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5D4037)),
            );
          }
          if (state is OrdersError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<OrdersCubit>().loadOrders(customerId),
            );
          }

          List<OrderEntity>? orders;
          if (state is OrdersLoaded) orders = state.orders;
          if (state is OrderStatusUpdating) orders = state.orders;
          if (state is OrderStatusUpdated) orders = state.orders;
          if (state is OrderStatusUpdateFailed) orders = state.orders;

          if (orders == null || orders.isEmpty) return const _EmptyView();

          final isUpdating = state is OrderStatusUpdating;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderCard(
              order: orders![index],
              customerId: customerId,
              isUpdating: isUpdating,
            ),
          );
        },
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final int customerId;
  final bool isUpdating;

  const _OrderCard({
    required this.order,
    required this.customerId,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product row ──
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: order.imageUrl != null
                      ? Image.network(
                          order.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C1810)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('Order #${order.id}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status, info: statusInfo),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),

            // ── Date ──
            if (order.createdAt != null)
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(_formatDate(order.createdAt!),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),

            const SizedBox(height: 12),

            // ── Progress stepper (read-only for customer) ──
            _StatusStepper(currentStatus: order.status),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        width: 60,
        height: 60,
        color: const Color(0xFFF3EDE8),
        child: const Icon(Icons.chair_alt, color: Color(0xFF5D4037), size: 28),
      );

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> _statusInfo(String status) {
    switch (status) {
      case 'Preparing':
        return {'color': Colors.orange, 'icon': Icons.restaurant_outlined};
      case 'Out for delivery':
        return {'color': Colors.blue, 'icon': Icons.delivery_dining};
      case 'Shipped':
        return {'color': Colors.green, 'icon': Icons.check_circle_outline};
      case 'Cancelled':
        return {'color': Colors.red, 'icon': Icons.cancel_outlined};
      default:
        return {'color': Colors.grey, 'icon': Icons.help_outline};
    }
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, dynamic> info;
  const _StatusBadge({required this.status, required this.info});

  @override
  Widget build(BuildContext context) {
    final color = info['color'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info['icon'] as IconData, size: 13, color: color),
          const SizedBox(width: 4),
          Text(status,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Status Stepper (read-only — customer can only track, not change) ─────────

class _StatusStepper extends StatelessWidget {
  final String currentStatus;
  const _StatusStepper({required this.currentStatus});

  static const _steps = ['Preparing', 'Out for delivery', 'Shipped'];

  @override
  Widget build(BuildContext context) {
    if (currentStatus == 'Cancelled') {
      return Row(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 16),
          const SizedBox(width: 6),
          Text('Order Cancelled',
              style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      );
    }

    final currentIndex = _steps.indexOf(currentStatus);

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? const Color(0xFF5D4037)
                  : Colors.grey.shade200,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isCompleted = stepIndex <= currentIndex;
        final isCurrent = stepIndex == currentIndex;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF5D4037)
                    : Colors.grey.shade200,
                border: isCurrent
                    ? Border.all(
                        color: const Color(0xFF5D4037).withOpacity(0.3),
                        width: 3)
                    : null,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: isCompleted ? 16 : 8,
                color: isCompleted ? Colors.white : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIndex].split(' ').first,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCompleted
                    ? const Color(0xFF5D4037)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Empty & Error ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 80, color: Color(0xFFBCAAA4)),
            SizedBox(height: 16),
            Text('No orders yet',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFBCAAA4),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
}
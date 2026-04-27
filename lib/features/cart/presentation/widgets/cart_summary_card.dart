import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_summary.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';

class CartSummaryCard extends StatefulWidget {
  final CartSummary summary;

  const CartSummaryCard({super.key, required this.summary});

  @override
  State<CartSummaryCard> createState() => _CartSummaryCardState();
}

class _CartSummaryCardState extends State<CartSummaryCard> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Promo code
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _promoController,
                    decoration: const InputDecoration(
                      hintText: 'Promo code',
                      hintStyle: TextStyle(
                          color: Color(0xFFB0A090),
                          fontSize: 14,
                          fontFamily: "Baloo2"),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_promoController.text.isNotEmpty) {
                    context.read<CartBloc>().add(
                          ApplyPromoCodeEvent(_promoController.text),
                        );
                  }
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D533D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: "Baloo2",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SummaryRow('Sub - Total', widget.summary.subTotal),
          const SizedBox(height: 10),
          _SummaryRow('Delivery Fee', widget.summary.deliveryFee),
          const SizedBox(height: 10),
          _SummaryRow('Discount', -widget.summary.discount,
              isDiscount: widget.summary.discount > 0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFEEE8E0), thickness: 1),
          ),
          _SummaryRow('Total Cost', widget.summary.totalCost, isTotal: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D533D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Baloo2",
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;
  final bool isDiscount;

  const _SummaryRow(
    this.label,
    this.amount, {
    this.isTotal = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmount = isDiscount
        ? '-\$ ${amount.abs().toStringAsFixed(2)}'
        : '\$ ${amount.toStringAsFixed(2)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              fontFamily: "Baloo2",
              color: const Color(0xFF3A2E26),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          displayAmount,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontFamily: "Baloo2",
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color:
                isDiscount ? const Color(0xFF7A5C3E) : const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../bloc/points_bloc.dart';
import '../../domain/models/points_model.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PointsBloc, PointsState>(
      listener: (context, state) {
        if (state is PointsEarned) {
          _showToast(context,
              '🎉 +${state.earnedAmount} points earned!',
              const Color(0xFF4A7C59));
        }
        if (state is PointsRedeemed) {
          _showToast(context,
              '✓ EGP ${state.discountValue} discount applied! ${state.remainingPoints} pts left',
              const Color(0xFF7D533D));
        }
        if (state is PointsError) {
          _showToast(context, state.message, Colors.red.shade400);
        }
      },
      builder: (context, state) {
        if (state is PointsLoading || state is PointsInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F5F1),
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF7D533D))),
          );
        }

        final points = state is PointsLoaded ? state.points : const PointsModel();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F5F1),
          body: CustomScrollView(
            slivers: [
              // ── Hero Header ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroHeader(
                  points: points,
                  onRedeem: points.canRedeem
                      ? () => _confirmRedeem(context, points)
                      : null,
                ),
              ),

              // ── How it works ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: _HowItWorksRow(),
                ),
              ),

              // ── Simulate Purchase ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _SimulateCard(
                    onPurchase: (amount) {
                      final orderId =
                          'ORD${Random().nextInt(9999).toString().padLeft(4, '0')}';
                      context.read<PointsBloc>().add(EarnPointsEvent(
                            purchaseAmount: amount,
                            orderId: orderId,
                          ));
                    },
                  ),
                ),
              ),

              // ── History Header ─────────────────────────────────────────
              if (points.transactions.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(children: [
                      const Text('History',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C1A0E))),
                      const Spacer(),
                      Text('${points.transactions.length} transactions',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ),
                ),

              // ── Transaction List ───────────────────────────────────────
              if (points.transactions.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _TransactionTile(
                        transaction: points.transactions[i],
                        isLast: i == points.transactions.length - 1,
                        onDelete: () => _confirmDelete(
                            context, points.transactions[i]),
                      ),
                      childCount: points.transactions.length,
                    ),
                  ),
                ),

              if (points.transactions.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyHistory(),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showToast(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _confirmRedeem(BuildContext context, PointsModel points) {
    final bloc = context.read<PointsBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF7D533D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.redeem_rounded,
                  color: Color(0xFF7D533D), size: 30),
            ),
            const SizedBox(height: 16),

            const Text('Use 100 Points?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C1A0E))),
            const SizedBox(height: 8),
            Text(
              'You\'ll get EGP ${PointsModel.discountValue} discount.\n${points.pointsAfterRedeem} points will remain.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Summary box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('Points Used', '100 pts',
                        const Color(0xFF7D533D)),
                    Container(width: 1, height: 36, color: Colors.grey.shade200),
                    _summaryItem('You Get', 'EGP 10',
                        const Color(0xFF4A7C59)),
                    Container(width: 1, height: 36, color: Colors.grey.shade200),
                    _summaryItem('Remaining',
                        '${points.pointsAfterRedeem} pts',
                        Colors.grey.shade600),
                  ]),
            ),
            const SizedBox(height: 24),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: Color(0xFF2C1A0E))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final orderId =
                        'ORD${Random().nextInt(9999).toString().padLeft(4, '0')}';
                    bloc.add(RedeemPointsEvent(orderId: orderId));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7D533D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Redeem Now',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(children: [
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  void _confirmDelete(BuildContext context, PointsTransaction tx) {
    final bloc = context.read<PointsBloc>();
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Transaction?'),
        content: Text(
            '${tx.isEarned ? '+' : '-'}${tx.points} pts — ${tx.description}\n\nThis will adjust your points balance.'),
        actions: [
          CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              bloc.add(DeleteTransactionEvent(tx.id));
            },
          ),
        ],
      ),
    );
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final PointsModel points;
  final VoidCallback? onRedeem;

  const _HeroHeader({required this.points, this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final progress = points.progressToNext;
    final canRedeem = points.canRedeem;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF7D533D),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar row
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 16),
                  ),
                ),
                const Spacer(),
                const Text('My Points',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                const SizedBox(width: 38),
              ]),
              const SizedBox(height: 28),

              // Points balance row
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Balance',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                    Text('${points.totalPoints}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('pts',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                    ),
                  ]),
                ]),
                const Spacer(),

                // Coin stack visual
                _CoinStack(points: points.totalPoints),
              ]),
              const SizedBox(height: 24),

              // Progress bar
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(
                    canRedeem
                        ? '🎉 Ready to redeem!'
                        : '${points.pointsToNext} pts to next EGP ${PointsModel.discountValue} off',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: canRedeem ? 1.0 : progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      canRedeem
                          ? const Color(0xFFFFD166)
                          : Colors.white.withOpacity(0.8),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('0',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 10)),
                  Text('100 pts = EGP 10',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 10)),
                ]),
              ]),

              // Redeem button
              if (canRedeem) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRedeem,
                    icon: const Icon(Icons.redeem_rounded,
                        color: Color(0xFF7D533D), size: 18),
                    label: const Text(
                      'Redeem 100 pts → EGP 10 Off',
                      style: TextStyle(
                          color: Color(0xFF7D533D),
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD166),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Coin Stack Visual ────────────────────────────────────────────────────────

class _CoinStack extends StatelessWidget {
  final int points;
  const _CoinStack({required this.points});

  @override
  Widget build(BuildContext context) {
    final coins = (points / 20).clamp(1, 8).toInt();
    return SizedBox(
      width: 60,
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: List.generate(coins, (i) {
          return Positioned(
            bottom: i * 8.0,
            child: Container(
              width: 50,
              height: 20,
              decoration: BoxDecoration(
                color: i == coins - 1
                    ? const Color(0xFFFFD166)
                    : const Color(0xFFE8B94A).withOpacity(0.6 + i * 0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 0.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── How It Works Row ─────────────────────────────────────────────────────────

class _HowItWorksRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(children: [
        _ruleChip(Icons.shopping_bag_outlined, 'EGP 10 = 1 pt'),
        const SizedBox(width: 8),
        _ruleChip(Icons.star_outline_rounded, '100 pts = EGP 10'),
        const SizedBox(width: 8),
        _ruleChip(Icons.lock_outline, 'One use only'),
      ]),
    );
  }

  Widget _ruleChip(IconData icon, String text) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Icon(icon, color: const Color(0xFF7D533D), size: 18),
            const SizedBox(height: 4),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C1A0E))),
          ]),
        ),
      );
}

// ─── Simulate Card ────────────────────────────────────────────────────────────

class _SimulateCard extends StatefulWidget {
  final void Function(double) onPurchase;
  const _SimulateCard({required this.onPurchase});

  @override
  State<_SimulateCard> createState() => _SimulateCardState();
}

class _SimulateCardState extends State<_SimulateCard> {
  final _ctrl = TextEditingController();
  int _preview = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFF7D533D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_long_outlined,
                color: Color(0xFF7D533D), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Simulate Purchase',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C1A0E))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final amt = double.tryParse(v) ?? 0;
                setState(
                    () => _preview = PointsModel.calculatePoints(amt));
              },
              decoration: InputDecoration(
                hintText: 'Order amount (EGP)',
                prefixText: 'EGP  ',
                filled: true,
                fillColor: const Color(0xFFF8F5F1),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF7D533D), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              final amount = double.tryParse(_ctrl.text);
              if (amount != null && amount > 0) {
                widget.onPurchase(amount);
                _ctrl.clear();
                setState(() => _preview = 0);
              }
            },
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7D533D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
        ]),
        if (_preview > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A7C59).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFF4A7C59), size: 14),
              const SizedBox(width: 6),
              Text('You\'ll earn $_preview points',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A7C59),
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final PointsTransaction transaction;
  final bool isLast;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEarned = transaction.isEarned;
    final color =
        isEarned ? const Color(0xFF4A7C59) : const Color(0xFF7D533D);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 22),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false; // الـ bloc هو اللي بيعمل الحذف
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            // Icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isEarned
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(transaction.description,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C1A0E))),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
              ]),
            ),

            // Points badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isEarned ? '+' : '-'}${transaction.points}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ),

            // Delete button
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close_rounded,
                  color: Colors.grey.shade300, size: 18),
            ),
          ]),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ─── Empty History ────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Column(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF7D533D).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_outlined,
              color: Color(0xFF7D533D), size: 32),
        ),
        const SizedBox(height: 16),
        const Text('No transactions yet',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C1A0E))),
        const SizedBox(height: 6),
        Text('Simulate a purchase above to earn your first points!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      ]),
    );
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:furnimatch/features/cart/presentation/bloc/cart_event.dart';
// // import 'package:furnimatch/features/RoomMeasurement/presentation/screen/room_setup_screen.dart';
// import 'package:furnimatch/features/home/data/models/home_repository.dart';
// import 'package:furnimatch/features/notifications/presentation/screen/notifications_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:furnimatch/features/buttom_nav/CustomBottomNav.dart';
// import 'package:furnimatch/features/cart/data/datasources/cart_local_datasource.dart';
// import 'package:furnimatch/features/cart/injection_container.dart';
// import 'package:furnimatch/features/cart/presentation/bloc/cart_bloc.dart';
// import 'package:furnimatch/features/cart/presentation/pages/cart_page.dart';
// import 'package:furnimatch/features/chat/data/models/chat_repository.dart';
// import 'package:furnimatch/features/chat/presentation/pages/user_chat_list_page.dart';
// import 'package:furnimatch/features/home/presentation/pages/home_page.dart';
// import 'package:furnimatch/features/profile/presentation/pages/profile_page.dart';
// import 'package:furnimatch/providers/cart_provider.dart';
// import 'package:furnimatch/features/RoomMeasurement/presentation/screen/rooms_entry_tab.dart';
// class MainShell extends StatefulWidget {
//   final int? userId;
//   final String? userName;
//   final int initialIndex;
  

//   const MainShell({
//     super.key,
//     this.userId,
//     this.userName,
//     this.initialIndex = 0,
//   });

//   static void openTab(
//     BuildContext context, {
//     required int index,
//     int? userId,
//     String? userName,
//   }) {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MainShell(
//           userId: userId,
//           userName: userName,
//           initialIndex: index,
//         ),
//       ),
//       (route) => false,
//     );
//   }

//   @override
//   State<MainShell> createState() => _MainShellState();
// }

// class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
//   int currentIndex = 0;
//   int? userId;
//   String? userName;
//   int unreadCount = 0;
//   int unreadNotifCount = 0;
//   late final ValueNotifier<String> _userNameNotifier;
//   Timer? _unreadRefreshTimer;
//   final _chatRepository = ChatRepository();
//   final _homeRepository = HomeRepository();

//   bool get isLoggedIn => userId != null;

//   @override
//   void initState() {
//     super.initState();
//     _userNameNotifier = ValueNotifier(widget.userName ?? ''); 
//     WidgetsBinding.instance.addObserver(this);
//     currentIndex = widget.initialIndex;
//     userId = widget.userId;
//     userName = widget.userName;
//     if (userId != null) {
//       sl<CartLocalDataSource>().setUserId(userId!);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           context.read<CartProvider>().fetchCartCount(userId!);
//           loadUnreadCount();
//           loadUnreadNotifCount();
//           startUnreadRefresh();
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//       _userNameNotifier.dispose(); 
//     _unreadRefreshTimer?.cancel();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   void startUnreadRefresh() {
//     _unreadRefreshTimer?.cancel();
//     if (!isLoggedIn) return;

//     _unreadRefreshTimer = Timer.periodic(
//       const Duration(seconds: 15),
//       (_) {
//         loadUnreadCount();
//         loadUnreadNotifCount();
//       },
//     );
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed && isLoggedIn) {
//       loadUnreadCount();
//       loadUnreadNotifCount();
//     }
//   }

//   Future<void> loadUnreadNotifCount() async {
//     final id = userId;
//     if (id == null) {
//       if (mounted) setState(() => unreadNotifCount = 0);
//       return;
//     }
//     try {
//       final count = await _homeRepository.fetchUnreadNotifCount(id);
//       if (mounted) setState(() => unreadNotifCount = count);
//     } catch (_) {
//       if (mounted) setState(() => unreadNotifCount = 0);
//     }
//   }

//   Future<void> loadUnreadCount() async {
//     final id = userId;
//     if (id == null) {
//       if (mounted) setState(() => unreadCount = 0);
//       return;
//     }
//     try {
//       final count = await _chatRepository.fetchUnreadCount(id);
//       if (mounted) setState(() => unreadCount = count);
//     } catch (_) {
//       if (mounted) setState(() => unreadCount = 0);
//     }
//   }
//  void updateAuth(int? id, String? name) {
//     setState(() {
//       userId = id;
//       userName = name;
//       if (id == null &&
//           (currentIndex == 1 || currentIndex == 4 || currentIndex == 5)) {
//         currentIndex = 0;
//       }
//     });
//      _userNameNotifier.value = name ?? '';

//     if (id != null) {
//       sl<CartLocalDataSource>().setUserId(id);
//       context.read<CartProvider>().fetchCartCount(id);
//       loadUnreadCount();
//       loadUnreadNotifCount();
//       startUnreadRefresh();
//     } else {
//       _unreadRefreshTimer?.cancel();
//       unreadCount = 0;
//       unreadNotifCount = 0;
//       context.read<CartProvider>().resetCartCount();
//     }
//   }

//   void goHome() {
//     setState(() => currentIndex = 0);
//     if (isLoggedIn) {
//       loadUnreadCount();
//       loadUnreadNotifCount();
//     }
//   }

//   List<Widget> get pages {
//     return [
//       HomeScreen(
//         key: const ValueKey('home'),
//         userId: userId,
//         userName: userName,
//         onAuthChanged: updateAuth,
//         onTabSelected: onNavTap,
//       ),
//       isLoggedIn
//           ? UserChatListPage(
//               key: ValueKey('inbox-$userId'),
//               currentUserId: userId!,
//               userName: userName,
//               onBackToHome: goHome,
//               onUnreadCountChanged: (count) {
//                 if (mounted) setState(() => unreadCount = count);
//               },
//             )
//           : const _LoginRequiredTab(),
//       isLoggedIn
//           ? NotificationsScreen(
//               key: ValueKey('notifications-$userId'),
//               userId: userId!,
//               onBack: () => onNavTap(0),
//             )
//           : const _LoginRequiredTab(),
//       // ✅ جديد
// isLoggedIn
//     ? RoomsEntryTab(userId: userId!, onBackToHome: goHome)
//     : const _LoginRequiredTab(),
//       isLoggedIn
//           ? BlocProvider(
//               key: ValueKey('cart-$userId'),
//               create: (_) => sl<CartBloc>(),
//               child: CartPage(
//                 userId: userId ?? 0,
//                 onBackToHome: goHome,
//               ),
//             )
//           : const _LoginRequiredTab(),
//      isLoggedIn
//     ? MyProfilePage(
//         key: ValueKey('profile-$userId'),
//         userId: userId!,
//         currentName: userName ?? '',
//         onBackToHome: goHome,
//         onNameUpdated: (newName) { 
//           setState(() => userName = newName);
//           _userNameNotifier.value = newName; 
//         },
//       )
//     : const _LoginRequiredTab(),
//     ];
//   }

// void onNavTap(int index) {
//   if (!isLoggedIn && index != 0) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please log in first!')),
//     );
//     setState(() => currentIndex = 0);
//     return;
//   }

//   if (index == 2) {
//     setState(() => unreadNotifCount = 0);
//   } else {
//     loadUnreadNotifCount();
//   }

//   // ✅ أضف السطرين دول
//   if (index == 4 && isLoggedIn) {
//     sl<CartLocalDataSource>().setUserId(userId!);
//     context.read<CartBloc>().add(LoadCartEvent()); // ← ده هو الحل
//   }

//   setState(() => currentIndex = index);

//   if (isLoggedIn) {
//     loadUnreadCount();
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: currentIndex,
//         children: pages,
//       ),
//       bottomNavigationBar: Consumer<CartProvider>(
//         builder: (context, cartProvider, _) {
//           return CustomBottomNav(
//             currentIndex: currentIndex,
//             cartCount: cartProvider.cartCount,
//             inboxCount: unreadCount,
//             notifCount: unreadNotifCount,
//             onTap: onNavTap,
//           );
//         },
//       ),
//     );
//   }
// }

// class _LoginRequiredTab extends StatelessWidget {
//   const _LoginRequiredTab();

//   @override
//   Widget build(BuildContext context) {
//     return const _ComingSoonTab(
//       icon: Icons.lock_outline,
//       title: 'Login Required',
//       message: 'Please log in first!',
//     );
//   }
// }

// class _ComingSoonTab extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String message;

//   const _ComingSoonTab({
//     required this.icon,
//     required this.title,
//     required this.message,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const bgColor = Color(0xFFF6F0E9);
//     const darkBrown = Color(0xFF7D533D);

//     return Scaffold(
//       backgroundColor: bgColor,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 72, color: darkBrown.withOpacity(0.35)),
//               const SizedBox(height: 16),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: darkBrown,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: darkBrown.withOpacity(0.7),
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furnimatch/features/cart/presentation/bloc/cart_event.dart';
import 'package:furnimatch/features/home/data/models/home_repository.dart';
import 'package:furnimatch/features/notifications/presentation/screen/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:furnimatch/features/buttom_nav/CustomBottomNav.dart';
import 'package:furnimatch/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:furnimatch/features/cart/injection_container.dart';
import 'package:furnimatch/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:furnimatch/features/cart/presentation/pages/cart_page.dart';
import 'package:furnimatch/features/chat/data/models/chat_repository.dart';
import 'package:furnimatch/features/chat/presentation/pages/user_chat_list_page.dart';
import 'package:furnimatch/features/home/presentation/pages/home_page.dart';
import 'package:furnimatch/features/profile/presentation/pages/profile_page.dart';
import 'package:furnimatch/providers/cart_provider.dart';
import 'package:furnimatch/features/RoomMeasurement/presentation/screen/rooms_entry_tab.dart';

// ✅ MainShell دلوقتي بس بيعمل BlocProvider وبيمرر كل حاجة لـ _MainShellBody
class MainShell extends StatelessWidget {
  final int? userId;
  final String? userName;
  final int initialIndex;

  const MainShell({
    super.key,
    this.userId,
    this.userName,
    this.initialIndex = 0,
  });

  static void openTab(
    BuildContext context, {
    required int index,
    int? userId,
    String? userName,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainShell(
          userId: userId,
          userName: userName,
          initialIndex: index,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CartBloc>(),
      child: _MainShellBody(
        userId: userId,
        userName: userName,
        initialIndex: initialIndex,
      ),
    );
  }
}

// ✅ كل الـ logic انتقل لهنا - دلوقتي context.read<CartBloc>() شغال لأن BlocProvider فوقيه
class _MainShellBody extends StatefulWidget {
  final int? userId;
  final String? userName;
  final int initialIndex;

  const _MainShellBody({
    this.userId,
    this.userName,
    this.initialIndex = 0,
  });

  @override
  State<_MainShellBody> createState() => _MainShellBodyState();
}

class _MainShellBodyState extends State<_MainShellBody>
    with WidgetsBindingObserver {
  int currentIndex = 0;
  bool _notificationsTabVisited = false;
  int? userId;
  String? userName;
  int unreadCount = 0;
  int unreadNotifCount = 0;
  late final ValueNotifier<String> _userNameNotifier;
  Timer? _unreadRefreshTimer;
  final _chatRepository = ChatRepository();
  final _homeRepository = HomeRepository();

  bool get isLoggedIn => userId != null;

  @override
  void initState() {
    super.initState();
    _userNameNotifier = ValueNotifier(widget.userName ?? '');
    WidgetsBinding.instance.addObserver(this);
    currentIndex = widget.initialIndex;
    userId = widget.userId;
    userName = widget.userName;

    if (userId != null) {
      sl<CartLocalDataSource>().setUserId(userId!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CartProvider>().fetchCartCount(userId!);
          context.read<CartBloc>().add(LoadCartEvent()); // ✅ يشتغل دلوقتي
          loadUnreadCount();
          loadUnreadNotifCount();
          startUnreadRefresh();
        }
      });
    }
  }

  @override
  void dispose() {
    _userNameNotifier.dispose();
    _unreadRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void startUnreadRefresh() {
    _unreadRefreshTimer?.cancel();
    if (!isLoggedIn) return;
    _unreadRefreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        loadUnreadCount();
        loadUnreadNotifCount();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isLoggedIn) {
      loadUnreadCount();
      loadUnreadNotifCount();
    }
  }

  Future<void> loadUnreadNotifCount() async {
    final id = userId;
    if (id == null) {
      if (mounted) setState(() => unreadNotifCount = 0);
      return;
    }
    try {
      final count = await _homeRepository.fetchUnreadNotifCount(id);
      if (mounted) setState(() => unreadNotifCount = count);
    } catch (_) {
      if (mounted) setState(() => unreadNotifCount = 0);
    }
  }

  Future<void> loadUnreadCount() async {
    final id = userId;
    if (id == null) {
      if (mounted) setState(() => unreadCount = 0);
      return;
    }
    try {
      final count = await _chatRepository.fetchUnreadCount(id);
      if (mounted) setState(() => unreadCount = count);
    } catch (_) {
      if (mounted) setState(() => unreadCount = 0);
    }
  }

  void updateAuth(int? id, String? name) {
    setState(() {
      userId = id;
      userName = name;
      if (id == null &&
          (currentIndex == 1 || currentIndex == 4 || currentIndex == 5)) {
        currentIndex = 0;
      }
    });
    _userNameNotifier.value = name ?? '';

    if (id != null) {
      sl<CartLocalDataSource>().setUserId(id);
      context.read<CartProvider>().fetchCartCount(id);
      context.read<CartBloc>().add(LoadCartEvent()); // ✅ يشتغل دلوقتي
      loadUnreadCount();
      loadUnreadNotifCount();
      startUnreadRefresh();
    } else {
      _unreadRefreshTimer?.cancel();
      unreadCount = 0;
      unreadNotifCount = 0;
      _notificationsTabVisited = false;
      context.read<CartProvider>().resetCartCount();
    }
  }

  void goHome() {
    setState(() => currentIndex = 0);
    if (isLoggedIn) {
      loadUnreadCount();
      loadUnreadNotifCount();
    }
  }

  List<Widget> get pages {
    return [
      HomeScreen(
        key: const ValueKey('home'),
        userId: userId,
        userName: userName,
        onAuthChanged: updateAuth,
        onTabSelected: onNavTap,
      ),
      isLoggedIn
          ? UserChatListPage(
              key: ValueKey('inbox-$userId'),
              currentUserId: userId!,
              userName: userName,
              onBackToHome: goHome,
              onUnreadCountChanged: (count) {
                if (mounted) setState(() => unreadCount = count);
              },
            )
          : const _LoginRequiredTab(),
      (isLoggedIn && _notificationsTabVisited)
          ? NotificationsScreen(
              key: ValueKey('notifications-$userId'),
              userId: userId!,
              onBack: () => onNavTap(0),
            )
          // placeholder خفيف لحد ما المستخدم يدوس على التاب فعليًا
          // (الـ widget ده مش بيظهر أبدًا لأن onNavTap بيغير الفلاج قبل ما الـ index يتحط على 2)
          : const SizedBox.shrink(),
      isLoggedIn
          ? RoomsEntryTab(userId: userId!, onBackToHome: goHome)
          : const _LoginRequiredTab(),
      isLoggedIn
          ? CartPage(
              key: ValueKey('cart-$userId'),
              userId: userId ?? 0,
              onBackToHome: goHome,
            )
          : const _LoginRequiredTab(),
      isLoggedIn
          ? MyProfilePage(
              key: ValueKey('profile-$userId'),
              userId: userId!,
              currentName: userName ?? '',
              onBackToHome: goHome,
              onNameUpdated: (newName) {
                setState(() => userName = newName);
                _userNameNotifier.value = newName;
              },
            )
          : const _LoginRequiredTab(),
    ];
  }

  void onNavTap(int index) {
    if (!isLoggedIn && index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first!')),
      );
      setState(() => currentIndex = 0);
      return;
    }

    if (index == 2) {
      _notificationsTabVisited = true; // مينلودشي الإشعارات إلا أول ما تتفتح بالفعل
      setState(() => unreadNotifCount = 0);
    } else {
      loadUnreadNotifCount();
    }

    if (index == 4 && isLoggedIn) {
      sl<CartLocalDataSource>().setUserId(userId!);
      context.read<CartBloc>().add(LoadCartEvent()); // ✅ يشتغل دلوقتي
    }

    setState(() => currentIndex = index);

    if (isLoggedIn) {
      loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return CustomBottomNav(
            currentIndex: currentIndex,
            cartCount: cartProvider.cartCount,
            inboxCount: unreadCount,
            notifCount: unreadNotifCount,
            onTap: onNavTap,
          );
        },
      ),
    );
  }
}

class _LoginRequiredTab extends StatelessWidget {
  const _LoginRequiredTab();

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonTab(
      icon: Icons.lock_outline,
      title: 'Login Required',
      message: 'Please log in first!',
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ComingSoonTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF6F0E9);
    const darkBrown = Color(0xFF7D533D);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: darkBrown.withOpacity(0.35)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: darkBrown,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkBrown.withOpacity(0.7),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
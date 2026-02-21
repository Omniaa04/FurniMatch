import 'package:flutter/material.dart';


import 'features/shipping/presentation/screen/shipping_address_screen.dart';
import 'features/product_details/presentation/screen/product_details_screen.dart';
import 'features/tracking/presentation/screen/order_tracking_screen.dart';
import 'features/location/presentation/screen/select_location_screen.dart';
import 'features/shipping/presentation/screen/save_address_screen.dart';
import 'features/notifications/presentation/screen/notifications_screen.dart';
import 'features/Favorite/presentation/screen/favorites_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // إخفاء شريط "Debug" من الزاوية العلوية
      debugShowCheckedModeBanner: false,

      title: 'Furniture App',

      // إعداد الثيم (الألوان والخطوط العامة)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5A3C)),
        useMaterial3: true,
      ),

      // الشاشة الرئيسية: شاشة Shipping Address
      //home: const ShippingAddressScreen(),
       //home: const ProductDetailsScreen(),
      //home: const OrderTrackingScreen(),
     // home: const SelectLocationScreen(),
     //home: const NotificationsScreen(),
     home: const FavoritesScreen(),
    );
  }
}

/* الشاشات القديمة - معمول لها comment
import 'features/product_details/presentation/screen/product_details_screen.dart';
import 'features/tracking/presentation/screen/order_tracking_screen.dart';
import 'features/location/presentation/screen/select_location_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furniture App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7D533D)),
        useMaterial3: true,
      ),
      // home: const ProductDetailsScreen(),
      // home: const OrderTrackingScreen(),
      // home: const SelectLocationScreen(),
    );
  }
}
*/
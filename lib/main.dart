import 'package:flutter/material.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
import 'package:furnimatch/features/cart/injection_container.dart';
import 'package:furnimatch/providers/cart_provider.dart';
import 'package:provider/provider.dart'; 
 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initCartDependencies();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainShell(),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:furnimatch/features/buttom_nav/main_shell.dart';
// import 'package:furnimatch/features/cart/injection_container.dart';
// import 'package:furnimatch/providers/cart_provider.dart';
// import 'package:provider/provider.dart'; 
 

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   initCartDependencies();
//   runApp(MultiProvider(providers: [
//     ChangeNotifierProvider(create: (_) => CartProvider()),
//   ], child: const MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MainShell(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:furnimatch/features/buttom_nav/main_shell.dart';
// import 'package:furnimatch/features/auth/presentation/pages/login_page.dart';
import 'package:furnimatch/features/cart/injection_container.dart';
import 'package:furnimatch/providers/auth_provider.dart';
import 'package:furnimatch/providers/cart_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initCartDependencies();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppStartup(),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<AuthProvider>().loadFromPrefs());
  }
@override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // لو لسه بيقرأ الـ prefs
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xfff6eadf),
        body: Center(child: CircularProgressIndicator(color: Colors.brown)),
      );
    }

    // دايماً روح MainShell — سواء logged in أو لأ
    return MainShell(
      userId: auth.userId,
      userName: auth.name,
    );
  }
}

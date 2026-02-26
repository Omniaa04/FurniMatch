import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furnimatch/features/splash/cubit/splash_cubit.dart';
import 'package:furnimatch/features/splash/cubit/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _matchSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _initializeAnimations();

    // Start the splash sequence when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashCubit>().startSplashSequence();
    });

    print('SplashScreen initialized');
  }

  void _initializeAnimations() {
    _matchSlideAnimation = Tween<double>(
      begin: 80.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _taglineFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD2B0),
      body: BlocConsumer<SplashCubit, SplashState>(


        listener: (context, state) {
        print('Splash State: ${state.runtimeType}');
  
       if (state is SplashShowText) {
       _animationController.forward();
      }

   if (state is SplashNavigateToOnboarding) {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  if (state is SplashNavigateToHome) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  if (state is SplashError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.red,
      ),
    );
  }
},

        builder: (context, state) {
          print('Building with state: ${state.runtimeType}');
          
          if (state is SplashShowLogo) {
            // Show only logo
            return Center(
              child: Image.asset(
                'assets/images/first.png',
                width: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.chair,
                      size: 100,
                      color: Color(0xFF8B6F47),
                    ),
                  );
                },
              ),
            );
          } else if (state is SplashShowText) {
            // Show animated text with tagline
            return Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo text Row containing both furni and Match
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // "furni" text with vase replacing the dot on "i"
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'furn',
                                  style: TextStyle(
                                    fontFamily: 'Baloo2',
                                    fontSize: 55,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCF8D5B),
                                    letterSpacing: 0,
                                    height: 1.0,
                                  ),
                                ),
                                // Vase/Lamp icon as the dot of "i"
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/vase.png',
                                      width: 25,
                                      height: 20,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.lightbulb,
                                          size: 25,
                                          color: Color(0xFFCF8D5B),
                                        );
                                      },
                                    ),
                                    // The stem of "i"
                                    Container(
                                      width: 8,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCF8D5B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // "Match" text with chair replacing the "a" - animated to slide up
                            Transform.translate(
                              offset: Offset(0, _matchSlideAnimation.value),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'M',
                                    style: TextStyle(
                                      fontFamily: 'Baloo2',
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFCF8D5B),
                                      letterSpacing: 0,
                                      height: 1.0,
                                    ),
                                  ),
                                  // Chair icon replacing the "a"
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Image.asset(
                                      'assets/images/chair.png',
                                      width: 30,
                                      height: 30,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.chair,
                                          size: 38,
                                          color: Color(0xFFCF8D5B),
                                        );
                                      },
                                    ),
                                  ),
                                  const Text(
                                    'tch',
                                    style: TextStyle(
                                      fontFamily: 'Baloo2',
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFCF8D5B),
                                      letterSpacing: 0,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Tagline - appears below the logo
                        const SizedBox(height: 0),
                        Opacity(
                          opacity: _taglineFadeAnimation.value,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 90.0),
                            child: Text(
                              'where furniture meets your style.',
                              style: TextStyle(
                                fontFamily: 'Baloo2',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff7D533D),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          
          // Initial state or loading
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF8B6F47),
            ),
          );
        },
      ),
    );
  }
}
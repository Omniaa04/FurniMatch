import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, int>(
            builder: (context, index) {
              final cubit = context.read<OnboardingCubit>();
              final data = onboardingList[index];

              return Container(
                color: const Color.fromARGB(255, 107, 71, 51), // brown background
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Skip
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_seen', true);

                         Navigator.pushReplacementNamed(context, '/home');
                   },
                        
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// Image
                    Image.asset(
                      data.image,
                      height: 220,
                    ),

                    const SizedBox(height: 30),

                    /// Title
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Baloo2",
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Description
                    Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70 ,
                      fontFamily : "Baloo2",
                      fontSize: 20,
                      ),
                      
                    ),

                    const Spacer(),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Back
                        index > 0
                            ? TextButton(
                                onPressed: cubit.previousPage,
                                child: const Text(
                                  "Back",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : const SizedBox(),

                        /// Next
                        TextButton(
                          onPressed: () async {
                            if (index == 2) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('onboarding_seen', true);

                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              cubit.nextPage();
                            }
                          },
                          child: const Text(
                            "Next",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
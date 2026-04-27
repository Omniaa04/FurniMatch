import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../data/datasources/ar_remote_datasource.dart';
import '../../data/repositories/ar_repository_impl.dart';
import '../../domain/usecases/get_ar_model_usecase.dart';
import '../bloc/ar_bloc.dart';
import '../bloc/ar_event.dart';
import '../bloc/ar_state.dart';

class ArViewPage extends StatelessWidget {
  final int productId;
  final String productName;

  const ArViewPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArBloc(
        getArModelUseCase: GetArModelUseCase(
          ArRepositoryImpl(ArRemoteDataSourceImpl()),
        ),
      )..add(LoadArModelEvent(productId)),
      child: _ArViewContent(productName: productName),
    );
  }
}

class _ArViewContent extends StatelessWidget {
  final String productName;
  const _ArViewContent({required this.productName});

  @override
  Widget build(BuildContext context) {
    const darkBrown = Color(0xFF8B5E3C);
    const bgColor = Color(0xFFF6F0E9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: darkBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          productName,
          style: const TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ArBloc, ArState>(
        builder: (context, state) {
          if (state is ArLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          if (state is ArError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ArNoModel) {
            return _buildNoModelState(context);
          }

          if (state is ArLoaded) {
            final isIos = Platform.isIOS;

            // iOS uses USDZ via Quick Look
            if (isIos && state.model.hasIosModel) {
              return _buildIosArView(state.model.usdzUrl!);
            }

            // Android uses GLB via model-viewer
            if (!isIos && state.model.hasAndroidModel) {
              return _buildAndroidArView(state.model.glbUrl!);
            }

            // Fallback if platform model not available
            return _buildNoModelState(context);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAndroidArView(String glbUrl) {
    return ModelViewer(
      src: glbUrl,
      alt: productName,
      ar: true,
      arModes: const ['scene-viewer', 'webxr', 'quick-look'],
      autoRotate: true,
      cameraControls: true,
      backgroundColor: const Color(0xFFF6F0E9),
    );
  }

  Widget _buildIosArView(String usdzUrl) {
    // iOS Quick Look AR via model_viewer_plus
    return ModelViewer(
      src: usdzUrl,
      alt: productName,
      ar: true,
      autoRotate: true,
      cameraControls: true,
      backgroundColor: const Color(0xFFF6F0E9),
    );
  }

  Widget _buildNoModelState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar,
            size: 80,
            color: Colors.brown.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            "No 3D model available\nfor this product yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.brown,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
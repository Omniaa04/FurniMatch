class ArModel {
  final int productId;
  final String? glbUrl;
  final String? usdzUrl;

  const ArModel({
    required this.productId,
    this.glbUrl,
    this.usdzUrl,
  });

  bool get hasAndroidModel => glbUrl != null && glbUrl!.isNotEmpty;
  bool get hasIosModel => usdzUrl != null && usdzUrl!.isNotEmpty;
}
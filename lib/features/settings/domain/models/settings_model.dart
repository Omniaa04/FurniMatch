class SettingsModel {
  final bool notificationsEnabled;
  final String language;
  final String? userName;
  final String? userEmail;
  final String? profileImagePath; // مسار الصورة المحفوظة محلياً

  const SettingsModel({
    this.notificationsEnabled = true,
    this.language = 'English',
    this.userName,
    this.userEmail,
    this.profileImagePath,
  });

  SettingsModel copyWith({
    bool? notificationsEnabled,
    String? language,
    String? userName,
    String? userEmail,
    String? profileImagePath,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationsEnabled': notificationsEnabled,
        'language': language,
        'userName': userName,
        'userEmail': userEmail,
        'profileImagePath': profileImagePath,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        language: json['language'] ?? 'English',
        userName: json['userName'],
        userEmail: json['userEmail'],
        profileImagePath: json['profileImagePath'],
      );
}
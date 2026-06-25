import 'package:flutter_test/flutter_test.dart';
import 'package:furnimatch/features/notifications/domain/notifications_controller.dart';

void main() {
  late NotificationsController controller;

  setUp(() {
    controller = NotificationsController();
  });

  group('Notifications Controller', () {
    test('should toggle unread filter correctly', () {
      // Initial state
      expect(controller.showUnreadOnly, false);

      // Act
      controller.toggleFilter(true);

      // Assert
      expect(controller.showUnreadOnly, true);

      // Act again
      controller.toggleFilter(false);

      // Assert
      expect(controller.showUnreadOnly, false);
    });
  });
}
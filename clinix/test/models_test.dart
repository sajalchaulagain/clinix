import 'package:clinix/shared/models/blood_request_model.dart';
import 'package:clinix/shared/models/chat_message_model.dart';
import 'package:clinix/shared/models/mental_health_result_model.dart';
import 'package:clinix/shared/models/notification_model.dart';
import 'package:clinix/shared/models/reminder_model.dart';
import 'package:clinix/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// JSON round-trip tests: models must survive a backend/Firestore round trip
/// without losing information. Guards the FastAPI integration contract.
void main() {
  group('UserModel', () {
    test('round-trips through JSON', () {
      final user = UserModel(
        id: 'u-1',
        fullName: 'Test User',
        email: 'test@example.com',
        role: UserRole.admin,
        phone: '9812345678',
        bloodGroup: 'O+',
        emergencyContact: '9800000000',
        emailVerified: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final decoded = UserModel.fromJson(user.toJson());

      expect(decoded.id, user.id);
      expect(decoded.fullName, user.fullName);
      expect(decoded.role, UserRole.admin);
      expect(decoded.isAdmin, isTrue);
      expect(decoded.bloodGroup, 'O+');
    });

    test('defaults to patient for unknown roles', () {
      final user = UserModel.fromJson({'id': 'x', 'role': 'superuser'});
      expect(user.role, UserRole.patient);
    });
  });

  group('ReminderModel', () {
    ReminderModel build() => ReminderModel(
          id: 'rem-1',
          medicineName: 'Paracetamol',
          dosage: '500mg',
          frequency: 'Twice daily',
          times: const ['08:00', '20:00'],
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          isEnabled: true,
        );

    test('round-trips through JSON', () {
      final original = build();
      final decoded = ReminderModel.fromJson(original.toJson());
      expect(decoded.medicineName, original.medicineName);
      expect(decoded.times, original.times);
      expect(decoded.isEnabled, isTrue);
    });

    test('isActiveToday respects the enabled flag and date window', () {
      expect(build().isActiveToday, isTrue);
      expect(build().copyWith(isEnabled: false).isActiveToday, isFalse);
    });

    test('notification ids are unique per time slot', () {
      final reminder = build();
      expect(reminder.notificationIdFor(0),
          isNot(equals(reminder.notificationIdFor(1))));
    });

    test('expired reminders are not active today', () {
      final expired = build().copyWith(
        endDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(expired.isActiveToday, isFalse);
    });
  });

  group('ChatMessageModel', () {
    test('round-trips through JSON', () {
      final message = ChatMessageModel(
        id: 'm-1',
        text: 'Hello',
        sender: ChatSender.user,
        createdAt: DateTime(2026, 1, 1, 10),
      );
      final decoded = ChatMessageModel.fromJson(message.toJson());
      expect(decoded.isFromUser, isTrue);
      expect(decoded.text, 'Hello');
    });
  });

  group('BloodRequestModel', () {
    test('round-trips with enums preserved', () {
      final request = BloodRequestModel(
        id: 'r-1',
        requesterName: 'Requester',
        bloodGroup: 'A+',
        units: 2,
        hospitalName: 'Hospital',
        location: 'Kathmandu',
        status: BloodRequestStatus.approved,
        createdAt: DateTime(2026, 1, 1),
        urgency: BloodRequestUrgency.critical,
      );
      final decoded = BloodRequestModel.fromJson(request.toJson());
      expect(decoded.status, BloodRequestStatus.approved);
      expect(decoded.urgency, BloodRequestUrgency.critical);
    });

    test('unknown enum values fall back safely', () {
      final decoded = BloodRequestModel.fromJson({
        'id': 'r-2',
        'status': 'unknown_status',
        'urgency': 'unknown_urgency',
      });
      expect(decoded.status, BloodRequestStatus.pending);
      expect(decoded.urgency, BloodRequestUrgency.normal);
    });
  });

  group('MentalHealthResultModel', () {
    test('band labels never read like a diagnosis', () {
      for (final band in WellbeingBand.values) {
        final result = MentalHealthResultModel(
          band: band,
          summary: 'x',
          observations: const [],
          copingSuggestions: const [],
          lifestyleSuggestions: const [],
          seekHelpGuidance: 'x',
        );
        expect(result.bandLabel.toLowerCase(),
            isNot(contains('disorder')),
            reason: 'Band label must stay non-diagnostic');
        expect(result.bandLabel.toLowerCase(),
            isNot(contains('you have')),
            reason: 'Band label must stay non-diagnostic');
      }
    });
  });

  group('NotificationModel', () {
    test('copyWith isRead and JSON round-trip', () {
      final item = NotificationModel(
        id: 'n-1',
        type: AppNotificationType.reminder,
        title: 't',
        body: 'b',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(item.copyWith(isRead: true).isRead, isTrue);

      final decoded = NotificationModel.fromJson(item.toJson());
      expect(decoded.type, AppNotificationType.reminder);
      expect(decoded.isRead, isFalse);
    });
  });
}

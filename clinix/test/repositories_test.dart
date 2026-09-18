import 'package:clinix/core/services/local_storage_service.dart';
import 'package:clinix/features/auth/data/mock_auth_repository.dart';
import 'package:clinix/features/blood/data/mock_blood_repository.dart';
import 'package:clinix/features/reminders/data/local_reminder_repository.dart';
import 'package:clinix/shared/models/blood_request_model.dart';
import 'package:clinix/shared/models/reminder_model.dart';
import 'package:clinix/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock repositories behave like the real contracts, so these tests validate
/// the EXACT behaviors the UI relies on today — and double as executable
/// documentation for the future API implementations.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockAuthRepository', () {
    late MockAuthRepository repository;

    Future<MockAuthRepository> createRepository() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      return MockAuthRepository(storage);
    }

    setUp(() async => repository = await createRepository());

    test('starts signed out', () {
      expect(repository.currentUser, isNull);
    });

    test('sign-in succeeds with any valid credentials', () async {
      final user = await repository.signIn(
        email: 'sita@example.com',
        password: 'password123',
      );
      expect(user.email, 'sita@example.com');
      expect(user.role, UserRole.patient);
      expect(repository.currentUser, isNotNull);
    });

    test('admin emails receive the admin role (demo rule)', () async {
      final user = await repository.signIn(
        email: 'admin@clinix.app',
        password: 'password123',
      );
      expect(user.isAdmin, isTrue);
    });

    test('short passwords are rejected', () {
      expect(
        () => repository.signIn(email: 'a@b.com', password: '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('sign-out clears the session', () async {
      await repository.signIn(email: 'a@b.com', password: '123456');
      await repository.signOut();
      expect(repository.currentUser, isNull);
    });

    test('session persists across repository instances', () async {
      SharedPreferences.setMockInitialValues({});
      final firstPrefs = await SharedPreferences.getInstance();
      final first = MockAuthRepository(LocalStorageService(firstPrefs));
      await first.signIn(email: 'persist@example.com', password: '123456');

      // New repository over the same prefs store simulates an app restart.
      final secondPrefs = await SharedPreferences.getInstance();
      final second = MockAuthRepository(LocalStorageService(secondPrefs));
      final restored = await second.authStateChanges().first;
      expect(restored?.email, 'persist@example.com');
    });
  });

  group('MockBloodRepository', () {
    final repository = MockBloodRepository();

    test('returns all stock without filters', () async {
      final stocks = await repository.getBloodStock();
      expect(stocks, isNotEmpty);
    });

    test('blood group filter works', () async {
      final stocks = await repository.getBloodStock(bloodGroup: 'O+');
      expect(stocks.every((s) => s.bloodGroup == 'O+'), isTrue);
    });

    test('availableOnly excludes empty stock', () async {
      final stocks = await repository.getBloodStock(availableOnly: true);
      expect(stocks.every((s) => s.unitsAvailable > 0), isTrue);
    });

    test('submitRequest stores a pending request visible in my requests',
        () async {
      final before = await repository.getMyRequests();
      await repository.submitRequest(
        BloodRequestModel(
          id: '',
          requesterName: 'Test',
          bloodGroup: 'B+',
          units: 1,
          hospitalName: 'Test Hospital',
          location: 'Kathmandu',
          status: BloodRequestStatus.pending,
          createdAt: DateTime.now(),
        ),
      );
      final after = await repository.getMyRequests();
      expect(after.length, before.length + 1);
      expect(after.first.status, BloodRequestStatus.pending);
    });
  });

  group('LocalReminderRepository', () {
    Future<LocalReminderRepository> createRepo() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      return LocalReminderRepository(storage);
    }

    ReminderModel sample() => ReminderModel(
          id: 'rem-test',
          medicineName: 'Ibuprofen',
          dosage: '400mg',
          frequency: 'Twice daily',
          times: const ['08:00', '20:00'],
          startDate: DateTime.now(),
          isEnabled: true,
        );

    test('save + reload round-trips through storage', () async {
      final repo = await createRepo();
      await repo.saveReminder(sample());

      final loaded = await repo.getReminders();
      expect(loaded.single.medicineName, 'Ibuprofen');
      expect(loaded.single.times, ['08:00', '20:00']);
    });

    test('setEnabled flips the flag', () async {
      final repo = await createRepo();
      await repo.saveReminder(sample());
      final updated = await repo.setEnabled('rem-test', false);
      expect(updated.isEnabled, isFalse);

      final loaded = await repo.getReminders();
      expect(loaded.single.isEnabled, isFalse);
    });

    test('delete removes the reminder', () async {
      final repo = await createRepo();
      await repo.saveReminder(sample());
      await repo.deleteReminder('rem-test');
      expect(await repo.getReminders(), isEmpty);
    });
  });
}

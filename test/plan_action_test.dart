import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:heart_connect/src/features/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Plan actions verification', () async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 1. Insert a test plan
    final planId = await db.into(db.dailyPlans).insert(DailyPlansCompanion(
      date: Value(todayDate),
      content: Value('Test Plan'),
      type: Value('Normal'),
      isCompleted: Value(false),
      sortOrder: Value(0),
      isGenerated: Value(false),
    ));

    // 2. Test movePlanToEnd
    // Insert another plan to have comparison
    await db.into(db.dailyPlans).insert(DailyPlansCompanion(
      date: Value(todayDate),
      content: Value('Another Plan'),
      type: Value('Normal'),
      sortOrder: Value(1),
    ));

    await db.movePlanToEnd(planId, todayDate);
    
    final updatedPlan = await (db.select(db.dailyPlans)..where((t) => t.id.equals(planId))).getSingle();
    expect(updatedPlan.sortOrder, greaterThan(1));

    // 3. Test reschedulePlan
    final newDate = todayDate.add(const Duration(days: 1));
    await db.reschedulePlan(planId, newDate);
    
    final rescheduledPlan = await (db.select(db.dailyPlans)..where((t) => t.id.equals(planId))).getSingle();
    expect(rescheduledPlan.date, equals(newDate));

    // 4. Test completePlan
    await db.completePlan(planId);
    final completedPlan = await (db.select(db.dailyPlans)..where((t) => t.id.equals(planId))).getSingle();
    expect(completedPlan.isCompleted, isTrue);

    // 5. Test deletePlan
    await db.deletePlan(planId);
    final deletedPlan = await (db.select(db.dailyPlans)..where((t) => t.id.equals(planId))).getSingleOrNull();
    expect(deletedPlan, isNull);
  });
}

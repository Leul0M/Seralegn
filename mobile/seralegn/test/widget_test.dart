import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seralegn/screens/worker/worker_marketplace_screen.dart';

void main() {
  testWidgets('WorkerMarketplaceScreen renders refresh button and triggers callback', (WidgetTester tester) async {
    bool refreshCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: WorkerMarketplaceScreen(
          availableJobs: const [],
          currentWorkerId: '0911223344',
          onClaimJobPressed: (_) {},
          onDetailsPressed: (_) {},
          onRenewPlanPressed: () {},
          onRefresh: () async {
            refreshCalled = true;
          },
        ),
      ),
    );

    // Verify marketplace header title is present
    expect(find.text('Job Marketplace'), findsOneWidget);

    // Verify refresh icon button is present
    final refreshBtn = find.byIcon(Icons.refresh_rounded);
    expect(refreshBtn, findsOneWidget);

    // Tap refresh button and verify callback
    await tester.tap(refreshBtn);
    await tester.pump();
    expect(refreshCalled, isTrue);
  });
}

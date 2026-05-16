// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_clearbit/otel_clearbit.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_clearbit-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('combined.find records industry + employees + credits', () async {
    await tracedClearbit<String>(
      operation: 'combined.find',
      invoke: () async => const ClearbitCallResult(
        value: 'ok',
        result: ClearbitResult(
          endpoint: 'combined',
          lookupEmail: 'jane@example.com',
          matchKind: 'exact',
          companyName: 'Example',
          companyDomain: 'example.com',
          companyEmployees: 240,
          industry: 'Software',
          seniority: 'director',
          creditsCharged: 1,
          rateLimitRemaining: 599,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('clearbit combined.find')!);
    expect(a['clearbit.company.employees'], 240);
    expect(a['clearbit.person.seniority'], 'director');
    expect(a['clearbit.credits.charged'], 1);
  });

  test('reveal.find records confidence + ip lookup', () async {
    await tracedClearbit<String>(
      operation: 'reveal.find',
      invoke: () async => const ClearbitCallResult(
        value: 'ok',
        result: ClearbitResult(
          endpoint: 'reveal',
          lookupIp: '203.0.113.1',
          revealKind: 'traffic',
          revealConfidence: 0.87,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('clearbit reveal.find')!);
    expect(a['clearbit.reveal.kind'], 'traffic');
    expect(a['clearbit.reveal.confidence'], 0.87);
  });

  test('not_found does NOT set span error', () async {
    await tracedClearbit<String>(
      operation: 'person.find',
      invoke: () async => const ClearbitCallResult(
        value: 'ok',
        result: ClearbitResult(errorKind: 'not_found', statusCode: 404),
      ),
    );
    expect(
      spans.findSpanByName('clearbit person.find')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('rate_limited sets span error', () async {
    await tracedClearbit<String>(
      operation: 'person.find',
      invoke: () async => const ClearbitCallResult(
        value: 'ok',
        result: ClearbitResult(errorKind: 'rate_limited', statusCode: 429),
      ),
    );
    expect(
      spans.findSpanByName('clearbit person.find')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutClearbitInstrumentationAsync(() async {
      await tracedClearbit<String>(
        operation: 'autocomplete.suggest',
        invoke: () async => const ClearbitCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('clearbit '), isEmpty);
  });
}

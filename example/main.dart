// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_clearbit/otel_clearbit.dart';

/// Traces Clearbit calls with OpenTelemetry.
///
/// `otel_clearbit` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Clearbit call in
/// [tracedClearbit]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'clearbit-example');

  // Wraps a Clearbit API call in a CLIENT span.
  final clearbitId = await tracedClearbit<String>(
    operation: 'person.find',
    invoke: () async {
      // Make the Clearbit call here, then report what it returned.
      const id = 'clearbit_8f3a2c';
      return const ClearbitCallResult(
          value: id,
          result: ClearbitResult(
              endpoint: 'person',
              lookupEmail: 'ada@example.com',
              lookupDomain: 'example',
              lookupIp: 'example',
              matchKind: 'exact',
              personId: 'person_8f3a2c',
              companyId: 'company_8f3a2c',
              companyName: 'example',
              companyDomain: 'example',
              companyEmployees: 1,
              companyAlexaRank: 1,
              industry: 'example',
              industryNaics: 'example',
              industrySic: 'example',
              location: 'example',
              countryCode: 'example',
              role: 'engineering',
              seniority: 'executive',
              revealKind: 'traffic',
              revealConfidence: 0.5,
              queuedForWebhook: true,
              rateLimitRemaining: 25,
              creditsCharged: 1,
              errorKind: 'not_found',
              errorMessage: 'example',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedClearbit person.find returned $clearbitId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutClearbitInstrumentationAsync.
  await runWithoutClearbitInstrumentationAsync(
    () => tracedClearbit<String>(
      operation: 'person.find',
      invoke: () async {
        const id = 'clearbit_8f3a2c';
        return const ClearbitCallResult(
            value: id,
            result: ClearbitResult(
                endpoint: 'person',
                lookupEmail: 'ada@example.com',
                lookupDomain: 'example',
                lookupIp: 'example',
                matchKind: 'exact',
                personId: 'person_8f3a2c',
                companyId: 'company_8f3a2c',
                companyName: 'example',
                companyDomain: 'example',
                companyEmployees: 1,
                companyAlexaRank: 1,
                industry: 'example',
                industryNaics: 'example',
                industrySic: 'example',
                location: 'example',
                countryCode: 'example',
                role: 'engineering',
                seniority: 'executive',
                revealKind: 'traffic',
                revealConfidence: 0.5,
                queuedForWebhook: true,
                rateLimitRemaining: 25,
                creditsCharged: 1,
                errorKind: 'not_found',
                errorMessage: 'example',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}

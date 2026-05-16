// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_clearbit_suppression.dart';

const _tracerName = 'dartastic_otel_libs_clearbit';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class ClearbitResult {
  const ClearbitResult({
    this.endpoint,
    this.lookupEmail,
    this.lookupDomain,
    this.lookupIp,
    this.matchKind,
    this.personId,
    this.companyId,
    this.companyName,
    this.companyDomain,
    this.companyEmployees,
    this.companyAlexaRank,
    this.industry,
    this.industryNaics,
    this.industrySic,
    this.location,
    this.countryCode,
    this.role,
    this.seniority,
    this.revealKind,
    this.revealConfidence,
    this.queuedForWebhook,
    this.rateLimitRemaining,
    this.creditsCharged,
    this.errorKind,
    this.errorMessage,
    this.statusCode,
  });

  /// `person`, `person.flexible`, `company`, `combined`, `discovery`,
  /// `reveal`, `prospector`, `risk`, `autocomplete`, `nameToDomain`,
  /// `logo`.
  final String? endpoint;

  final String? lookupEmail;
  final String? lookupDomain;
  final String? lookupIp;

  /// `exact`, `flexible`, `none`, `queued`.
  final String? matchKind;

  final String? personId;
  final String? companyId;

  final String? companyName;
  final String? companyDomain;
  final int? companyEmployees;
  final int? companyAlexaRank;

  /// Industry classification labels.
  final String? industry;
  final String? industryNaics;
  final String? industrySic;

  /// `city, region, country` string.
  final String? location;

  /// ISO-3166 alpha-2.
  final String? countryCode;

  /// `engineering`, `sales`, `marketing`, `finance`, ...
  final String? role;

  /// `executive`, `director`, `manager`, `vp`, `c_suite`, `owner`,
  /// `entry`.
  final String? seniority;

  /// Reveal: `traffic`, `domain`.
  final String? revealKind;
  final double? revealConfidence;

  /// 202 enqueued — result will arrive on webhook.
  final bool? queuedForWebhook;

  final int? rateLimitRemaining;

  /// Credits charged for this call (Clearbit's primary billing dimension).
  final int? creditsCharged;

  /// `not_found`, `invalid_email`, `invalid_domain`, `unauthorized`,
  /// `forbidden`, `rate_limited`, `monthly_quota_exceeded`,
  /// `server_error`.
  final String? errorKind;
  final String? errorMessage;
  final int? statusCode;
}

class ClearbitCallResult<T> {
  const ClearbitCallResult({required this.value, this.result});
  final T value;
  final ClearbitResult? result;
}

/// Wraps a Clearbit API call in a CLIENT span. [operation] is one of
/// `person.find`, `person.flexibleFind`, `company.find`,
/// `combined.find`, `discovery.search`, `reveal.find`,
/// `prospector.search`, `risk.calculate`, `autocomplete.suggest`,
/// `nameToDomain.find`, `logo.get`, `webhook.parse`.
Future<T> tracedClearbit<T>({
  required String operation,
  required Future<ClearbitCallResult<T>> Function() invoke,
}) async {
  if (clearbitInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'clearbit',
    'rpc.method': operation,
    'clearbit.operation': operation,
  };

  final span = _tracer().startSpan(
    'clearbit $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.endpoint != null) {
        extras.add(OTel.attributeString('clearbit.endpoint', res.endpoint!));
      }
      if (res.lookupEmail != null) {
        extras.add(OTel.attributeString(
          'clearbit.lookup.email',
          res.lookupEmail!,
        ));
      }
      if (res.lookupDomain != null) {
        extras.add(OTel.attributeString(
          'clearbit.lookup.domain',
          res.lookupDomain!,
        ));
      }
      if (res.lookupIp != null) {
        extras.add(OTel.attributeString(
          'clearbit.lookup.ip',
          res.lookupIp!,
        ));
      }
      if (res.matchKind != null) {
        extras.add(OTel.attributeString(
          'clearbit.match.kind',
          res.matchKind!,
        ));
      }
      if (res.personId != null) {
        extras.add(OTel.attributeString(
          'clearbit.person.id',
          res.personId!,
        ));
      }
      if (res.companyId != null) {
        extras.add(OTel.attributeString(
          'clearbit.company.id',
          res.companyId!,
        ));
      }
      if (res.companyName != null) {
        extras.add(OTel.attributeString(
          'clearbit.company.name',
          res.companyName!,
        ));
      }
      if (res.companyDomain != null) {
        extras.add(OTel.attributeString(
          'clearbit.company.domain',
          res.companyDomain!,
        ));
      }
      if (res.companyEmployees != null) {
        extras.add(OTel.attributeInt(
          'clearbit.company.employees',
          res.companyEmployees!,
        ));
      }
      if (res.companyAlexaRank != null) {
        extras.add(OTel.attributeInt(
          'clearbit.company.alexa_rank',
          res.companyAlexaRank!,
        ));
      }
      if (res.industry != null) {
        extras.add(OTel.attributeString(
          'clearbit.company.industry',
          res.industry!,
        ));
      }
      if (res.industryNaics != null) {
        extras.add(OTel.attributeString(
          'clearbit.company.industry_naics',
          res.industryNaics!,
        ));
      }
      if (res.industrySic != null) {
        extras.add(OTel.attributeString(
          'clearbit.company.industry_sic',
          res.industrySic!,
        ));
      }
      if (res.location != null) {
        extras.add(OTel.attributeString(
          'clearbit.location',
          res.location!,
        ));
      }
      if (res.countryCode != null) {
        extras.add(OTel.attributeString(
          'clearbit.country_code',
          res.countryCode!,
        ));
      }
      if (res.role != null) {
        extras.add(OTel.attributeString('clearbit.person.role', res.role!));
      }
      if (res.seniority != null) {
        extras.add(OTel.attributeString(
          'clearbit.person.seniority',
          res.seniority!,
        ));
      }
      if (res.revealKind != null) {
        extras.add(OTel.attributeString(
          'clearbit.reveal.kind',
          res.revealKind!,
        ));
      }
      if (res.revealConfidence != null) {
        extras.add(OTel.attributeDouble(
          'clearbit.reveal.confidence',
          res.revealConfidence!,
        ));
      }
      if (res.queuedForWebhook != null) {
        extras.add(OTel.attributeBool(
          'clearbit.queued_for_webhook',
          res.queuedForWebhook!,
        ));
      }
      if (res.rateLimitRemaining != null) {
        extras.add(OTel.attributeInt(
          'clearbit.rate_limit.remaining',
          res.rateLimitRemaining!,
        ));
      }
      if (res.creditsCharged != null) {
        extras.add(OTel.attributeInt(
          'clearbit.credits.charged',
          res.creditsCharged!,
        ));
      }
      if (res.errorKind != null) {
        extras.add(OTel.attributeString(
          'clearbit.error.kind',
          res.errorKind!,
        ));
        if (res.errorKind != 'not_found') {
          span.setStatus(SpanStatusCode.Error, 'Clearbit ${res.errorKind}');
        }
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'clearbit.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400 && res.statusCode! != 404) {
          span.setStatus(
            SpanStatusCode.Error,
            'Clearbit HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

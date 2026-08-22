// Fayda ID QR decoder — pure Dart port of the JS fayda-decoder library.
// No network calls, no dependencies — runs 100% on-device.

import 'dart:convert';

/// A successfully decoded Fayda card.
class FaydaSuccess {
  final String fullName;
  final String? gender; // "M" or "F"
  final String? fan; // Fayda Account Number
  final String? dateOfBirth; // ISO yyyy-mm-dd
  final List<int>? faceBytes; // WebP image bytes (null unless includeFace: true)
  final String payloadVersion;
  final String rawPayload;
  final Map<String, String> rawMap;

  const FaydaSuccess({
    required this.fullName,
    this.gender,
    this.fan,
    this.dateOfBirth,
    this.faceBytes,
    required this.payloadVersion,
    required this.rawPayload,
    required this.rawMap,
  });

  /// First word of the full name.
  String get firstName {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  /// Everything after the first word (father's name / surname).
  String get fatherName {
    final parts = fullName.trim().split(' ');
    if (parts.length > 1) return parts.sublist(1).join(' ');
    return '';
  }

  /// Last 4 digits of the FAN.
  String get lastFanDigits {
    if (fan == null || fan!.length < 4) return fan ?? '';
    return fan!.substring(fan!.length - 4);
  }

  /// Masked display: "•••• •••• XXXX"
  String get maskedFan => fan != null ? '•••• •••• $lastFanDigits' : '—';

  String get genderLabel {
    if (gender == 'M') return 'Male';
    if (gender == 'F') return 'Female';
    return '—';
  }
}

class FaydaFailure {
  final FaydaErrorCode code;
  final String message;
  const FaydaFailure({required this.code, required this.message});
}

sealed class FaydaResult {}

class FaydaResultOk extends FaydaResult {
  final FaydaSuccess data;
  FaydaResultOk(this.data);
}

class FaydaResultErr extends FaydaResult {
  final FaydaFailure error;
  FaydaResultErr(this.error);
}

enum FaydaErrorCode { noQrFound, qrUnreadable, notFayda, unsupportedVersion }

const _supportedVersions = {'4'};

FaydaResult decodePayload(String text, {bool includeFace = false}) {
  final payload = text.trim();

  if (!payload.contains(':DLT:') || !payload.contains(':SIGN:')) {
    return FaydaResultErr(const FaydaFailure(
      code: FaydaErrorCode.notFayda,
      message: 'Not a recognizable Fayda ID QR. Scan the BACK of the card.',
    ));
  }

  final dltIdx = payload.indexOf(':DLT:');
  final facePart = payload.substring(0, dltIdx);
  final rest = payload.substring(dltIdx + ':DLT:'.length);
  final signIdx = rest.indexOf(':SIGN:');

  if (signIdx == -1) {
    return FaydaResultErr(const FaydaFailure(
      code: FaydaErrorCode.notFayda,
      message: 'Not a recognizable Fayda ID QR. Scan the BACK of the card.',
    ));
  }

  final fieldsPart = rest.substring(0, signIdx);
  final segments = fieldsPart.split(':');
  final fullName = segments.isNotEmpty ? segments.first.trim() : '';

  if (fullName.isEmpty) {
    return FaydaResultErr(const FaydaFailure(
      code: FaydaErrorCode.notFayda,
      message: 'Not a recognizable Fayda ID QR. Scan the BACK of the card.',
    ));
  }

  final tail = segments.sublist(1);
  final rawMap = <String, String>{};
  for (var i = 0; i + 1 < tail.length; i += 2) {
    rawMap[tail[i]] = tail[i + 1];
  }

  final version = rawMap['V'];
  if (version == null || !_supportedVersions.contains(version)) {
    return FaydaResultErr(FaydaFailure(
      code: FaydaErrorCode.unsupportedVersion,
      message: 'Unsupported Fayda payload version: $version.',
    ));
  }

  return FaydaResultOk(FaydaSuccess(
    fullName: fullName,
    gender: _parseGender(rawMap['G']),
    fan: _parseFan(rawMap['A']),
    dateOfBirth: _parseDob(rawMap['D']),
    faceBytes: includeFace ? _parseFace(facePart) : null,
    payloadVersion: version,
    rawPayload: payload,
    rawMap: rawMap,
  ));
}

String? _parseGender(String? v) => (v == 'M' || v == 'F') ? v : null;

String? _parseFan(String? v) {
  if (v == null) return null;
  return RegExp(r'^\d{10,20}$').hasMatch(v) ? v : null;
}

String? _parseDob(String? v) {
  if (v == null) return null;
  final m = RegExp(r'^(\d{4})/(\d{2})/(\d{2})$').firstMatch(v);
  if (m == null) return null;
  try {
    final dt = DateTime.utc(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
    if (dt.year != int.parse(m.group(1)!) || dt.month != int.parse(m.group(2)!) || dt.day != int.parse(m.group(3)!)) return null;
    return '${m.group(1)}-${m.group(2)}-${m.group(3)}';
  } catch (_) {
    return null;
  }
}

List<int>? _parseFace(String facePart) {
  if (facePart.isEmpty) return null;
  try {
    var b64 = facePart.replaceAll('-', '+').replaceAll('_', '/');
    final rem = b64.length % 4;
    if (rem != 0) b64 += '=' * (4 - rem);
    final bytes = base64.decode(b64);
    if (bytes.length < 4) return null;
    if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) {
      return bytes;
    }
    return null;
  } catch (_) {
    return null;
  }
}

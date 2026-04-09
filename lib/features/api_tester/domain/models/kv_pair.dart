// kv_pair.dart
// Purpose: Immutable model for a key-value pair with an enabled flag, used in headers, params, and form fields.

class KVPair {
  const KVPair({
    required this.key,
    required this.value,
    this.enabled = true,
  });

  final String key;
  final String value;
  final bool enabled;

  KVPair copyWith({String? key, String? value, bool? enabled}) {
    return KVPair(
      key: key ?? this.key,
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
    );
  }

  bool get isEmpty => key.isEmpty && value.isEmpty;

  @override
  String toString() => 'KVPair(key: $key, value: $value, enabled: $enabled)';
}

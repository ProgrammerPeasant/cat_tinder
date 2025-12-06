import 'package:flutter/foundation.dart';

String webSafeImageUrl(String url) {
  if (!kIsWeb) {
    return url;
  }
  final sanitized = url.replaceFirst(RegExp(r'^https?://'), '');
  final encoded = Uri.encodeComponent(sanitized);
  return 'https://images.weserv.nl/?url=$encoded&output=webp';
}

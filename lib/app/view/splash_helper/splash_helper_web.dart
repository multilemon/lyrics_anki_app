import 'package:web/web.dart' as web;

void removeSplash() {
  try {
    web.document.getElementById('app_skeleton')?.remove();
    web.document.getElementById('splash')?.remove();
    web.document.getElementById('splash-branding')?.remove();
    web.document.body?.style.background = 'transparent';
  } on Object catch (_) {
    // Ignore
  }
}

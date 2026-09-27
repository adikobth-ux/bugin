// Настраивает папки платформ после `flutter create`: название «Bugin»,
// языки (ru, kk), иконку и заставку. Запуск из корня проекта:
//
//   flutter create . --platforms=android,ios,web --org kz.bugin --project-name bugin
//   flutter pub get
//   dart run tool/setup_platforms.dart
//
// Скрипт можно запускать повторно: он меняет только то, что ещё не настроено.
import 'dart:convert';
import 'dart:io';

const appName = 'Bugin';
const appDescription = 'Bugin — чем заняться сегодня';
const themeColor = '#5B5BF0';
const backgroundColor = '#F5F6FB';
const languages = ['ru', 'kk'];

Future<void> main() async {
  _android();
  _ios();
  _web();
  await _run(['run', 'flutter_launcher_icons']);
  await _run(['run', 'flutter_native_splash:create']);
  stdout.writeln('Платформы настроены: $appName, иконка, заставка, языки ${languages.join(', ')}.');
}

void _android() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    return;
  }
  final text = manifest.readAsStringSync();
  final updated = text.replaceFirst(
    RegExp(r'android:label="[^"]*"'),
    'android:label="$appName"',
  );
  _write(manifest, text, updated);
}

void _ios() {
  final plist = File('ios/Runner/Info.plist');
  if (!plist.existsSync()) {
    return;
  }
  final text = plist.readAsStringSync();
  var updated = _setPlistString(text, 'CFBundleDisplayName', appName);
  updated = _setPlistString(updated, 'CFBundleName', appName);
  if (!updated.contains('<key>CFBundleLocalizations</key>')) {
    // Без этого списка iOS не отдаёт приложению казахский язык системы.
    final items = languages.map((code) => '\t\t<string>$code</string>').join('\n');
    updated = updated.replaceFirst(
      RegExp(r'</dict>\s*</plist>\s*$'),
      '\t<key>CFBundleLocalizations</key>\n\t<array>\n$items\n\t</array>\n</dict>\n</plist>\n',
    );
  }
  _write(plist, text, updated);
}

String _setPlistString(String plist, String key, String value) => plist.replaceFirstMapped(
      RegExp('(<key>$key</key>\\s*<string>)[^<]*(</string>)'),
      (m) => '${m[1]}$value${m[2]}',
    );

void _web() {
  final index = File('web/index.html');
  if (index.existsSync()) {
    final text = index.readAsStringSync();
    final updated = text
        .replaceFirst(RegExp(r'<title>[^<]*</title>'), '<title>$appName</title>')
        .replaceFirst(
          RegExp(r'<meta name="apple-mobile-web-app-title" content="[^"]*">'),
          '<meta name="apple-mobile-web-app-title" content="$appName">',
        )
        .replaceFirst(
          RegExp(r'<meta name="description" content="[^"]*">'),
          '<meta name="description" content="$appDescription">',
        );
    _write(index, text, updated);
  }

  final manifest = File('web/manifest.json');
  if (manifest.existsSync()) {
    final text = manifest.readAsStringSync();
    final json = jsonDecode(text) as Map<String, dynamic>
      ..['name'] = appName
      ..['short_name'] = appName
      ..['description'] = appDescription
      ..['theme_color'] = themeColor
      ..['background_color'] = backgroundColor;
    _write(manifest, text, '${const JsonEncoder.withIndent('    ').convert(json)}\n');
  }
}

void _write(File file, String before, String after) {
  if (before != after) {
    file.writeAsStringSync(after);
    stdout.writeln('Обновлён ${file.path}');
  }
}

Future<void> _run(List<String> args) async {
  stdout.writeln('\$ dart ${args.join(' ')}');
  final process = await Process.start(
    'dart',
    args,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    stderr.writeln('Команда «dart ${args.join(' ')}» завершилась с кодом $code');
    exit(code);
  }
}

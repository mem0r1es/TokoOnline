import 'dart:html' as html;

int? loadSelectedIndex() {
  final saved = html.window.localStorage['selectedIndex'];
  return saved != null ? int.tryParse(saved) : null;
}

void saveSelectedIndex(int index) {
  html.window.localStorage['selectedIndex'] = index.toString();
}

import 'package:cardblaze/l10n/app_localizations.dart';

// Localized name of a deck color from the palette (used as tooltip).
String deckColorName(AppLocalizations l, String hex) {
  switch (hex.toUpperCase()) {
    case '4A9EFF':
      return l.color_blue;
    case '43A047':
      return l.color_green;
    case '7B4FA0':
      return l.color_purple;
    case 'F57C00':
      return l.color_orange;
    case '00ACC1':
      return l.color_teal;
    case 'E91E63':
      return l.color_pink;
    default:
      return '#$hex';
  }
}

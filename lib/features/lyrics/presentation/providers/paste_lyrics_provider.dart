import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'paste_lyrics_provider.g.dart';

/// Signals the home page to reveal the "paste lyrics" text field.
///
/// Set to `true` from the error view when the user taps
/// "Paste Your Own Lyrics", then reset by the home page after consuming.
@riverpod
class ShowPasteLyrics extends _$ShowPasteLyrics {
  @override
  bool build() => false;

  void show() => state = true;

  void reset() => state = false;
}

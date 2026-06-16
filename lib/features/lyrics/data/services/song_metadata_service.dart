import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;
import 'package:lyrics_anki_app/features/lyrics/domain/entities/song_metadata.dart';
import 'package:retry/retry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_metadata_service.g.dart';

@Riverpod(keepAlive: true)
SongMetadataService songMetadataService(Ref ref) {
  return SongMetadataService();
}

class SongMetadataService {
  Future<SongMetadata> fetchMetadata({
    required String title,
    required String artist,
  }) async {
    // 1. Fetch Video using AI Google Search
    // We treat the "normalization" and "YouTube ID fetch" as a single AI step.
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        tools: [Tool.googleSearch()],
        generationConfig: GenerationConfig(
          temperature: 0,
        ),
      );

      final prompt = 'Identify the exact official song title and artist for '
          '"$title" by "$artist", and find its official YouTube music video. '
          'Return JSON: {"title":"Exact Song Title (without any tags like MV, '
          'Official, Audio, brackets, etc.)", "artist":"Exact Artist Name", '
          '"youtube_url":"https://www.youtube.com/watch?v=ID"}. '
          'CRITICAL FOR ARTIST NAME: If the artist uses an English/Romaji '
          'stage name on international platforms (like Spotify/Apple Music), '
          'return THAT Romaji name instead of the Japanese script '
          '(e.g. return "Shimamo" instead of "しまも"). '
          'If no video is found, still return the cleaned title and artist '
          'with an empty youtube_url.';

      final content = [Content.text(prompt)];
      final response = await retry(
        () => model.generateContent(content),
        retryIf: (e) => e is FirebaseAIException || e is http.ClientException,
        maxAttempts: 3,
      );
      final text = response.text;

      if (text == null) {
        throw Exception('AI returned null response');
      }

      // Cleanup optional markdown wrappers from AI
      final cleanJson =
          text.replaceAll('```json', '').replaceAll('```', '').trim();

      final json = jsonDecode(cleanJson) as Map<String, dynamic>;
      final youtubeUrl = json['youtube_url']?.toString() ?? '';
      final youtubeId = _extractYoutubeId(youtubeUrl) ?? '';

      if (youtubeId.isEmpty) {
        // throw Exception(
        //   'AI could not find a valid VIDEO ID from URL: $youtubeUrl',
        // );
      }

      return SongMetadata(
        title: json['title']?.toString() ?? title,
        artist: json['artist']?.toString() ?? artist,
        youtubeId: youtubeId,
      );
    } catch (e) {
      rethrow;
    }
  }

  String? _extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }
}

import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/song_metadata.dart';
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

      final prompt = 'Find official YouTube video for "$title" by "$artist". '
          'Return JSON: {"title":"Official Song\'s Title","artist":"Official Artist Name",'
          ' "youtube_url":"https://www.youtube.com/watch?v=ID"}'
          ' If not found: {"youtube_url":""}.';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
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

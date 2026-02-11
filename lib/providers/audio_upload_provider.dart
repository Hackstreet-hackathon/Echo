import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final audioUploadProvider =
    StateNotifierProvider<AudioUploadNotifier, AsyncValue<Map<String, dynamic>?>>(
  (ref) => AudioUploadNotifier(),
);

class AudioUploadNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  AudioUploadNotifier() : super(const AsyncValue.data(null));

  Future<void> uploadAudio(File file) async {
    try {
      state = const AsyncValue.loading();

     var uri = Uri.parse("http://192.168.1.7:5000/upload_audio");


      var request = http.MultipartRequest("POST", uri);
      request.files.add(
        await http.MultipartFile.fromPath("file", file.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);

        state = AsyncValue.data(data);
      } else {
        state = AsyncValue.error("Upload failed", StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

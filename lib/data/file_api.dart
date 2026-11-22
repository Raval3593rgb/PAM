
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class FileApi {
  FileApi(
    this.baseUrl,
    this.tokens, {
    this.onUnauthorized,
  });

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 20);
  static const _maxFileSize = 5 * 1024 * 1024;

  // POST /files — загрузка фотографии на FastAPI
  Future<Result<String>> upload(String path) async {
    try {
      final file = File(path);

      // Сервер принимает файлы до 5 МБ
      if (await file.length() > _maxFileSize) {
        return const Err<String>(
          'Фотография слишком большая. Максимум 5 МБ.',
        );
      }

      final token = await tokens.read();

      if (token == null) {
        return const Err<String>(
          'Необходимо войти в аккаунт',
        );
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          path,
        ),
      );

      final streamedResponse =
          await request.send().timeout(_timeout);

      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_timeout);

      if (response.statusCode == 401) {
        await tokens.clear();
        onUnauthorized?.call();

        return const Err<String>(
          'Сессия истекла. Войдите снова.',
        );
      }

      if (response.statusCode != 201) {
        return Err<String>(apiMessage(response));
      }

      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final url = data['url'] as String;

      return Ok<String>(url);
    } on TimeoutException {
      return const Err<String>('Сервер не отвечает');
    } on SocketException {
      return const Err<String>('Нет сети');
    } on FileSystemException {
      return const Err<String>('Не удалось прочитать фотографию');
    } on http.ClientException {
      return const Err<String>('Ошибка соединения');
    } on FormatException {
      return const Err<String>('Некорректный ответ сервера');
    } on TypeError {
      return const Err<String>('Некорректный ответ сервера');
    } catch (_) {
      return const Err<String>('Не удалось загрузить фотографию');
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/pet.dart';
import '../api_message.dart';
import '../result.dart';
import '../token_store.dart';
import 'pet_repository.dart';

class HttpPetRepository implements PetRepository {
  HttpPetRepository(
    this.baseUrl,
    this.tokens, {
    this.onUnauthorized,
  });

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  // Заголовки с JWT-токеном
  Future<Map<String, String>> _headers() async {
    final token = await tokens.read();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Истёкший или недействительный JWT
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  // Общая обработка HTTP-запросов
  Future<Result<T>> _execute<T>(
    Future<http.Response> Function() request,
    int expectedStatus,
    T Function(http.Response) decode,
  ) async {
    try {
      final response = await request().timeout(_timeout);

      // Авторизация больше недействительна
      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      // Ошибка со стороны FastAPI
      if (response.statusCode != expectedStatus) {
        return Err(apiMessage(response));
      }

      // Успешный ответ
      return Ok(decode(response));
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on http.ClientException {
      return const Err('Ошибка соединения с сервером');
    } on FormatException {
      return const Err('Некорректный ответ сервера');
    } on TypeError {
      return const Err('Некорректный ответ сервера');
    }
  }

  // GET /pets — получить список питомцев с пагинацией и поиском
  @override
  Future<Result<List<Pet>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final uri = Uri.parse('$baseUrl/pets').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
      },
    );

    return _execute<List<Pet>>(
      () async => http.get(
        uri,
        headers: await _headers(),
      ),
      200,
      (response) {
        final data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final items = data['items'] as List<dynamic>;

        return items
            .map((item) =>
                Pet.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // GET /pets/{id} — получить одного питомца
  @override
  Future<Result<Pet>> fetchById(int id) {
    return _execute<Pet>(
      () async => http.get(
        Uri.parse('$baseUrl/pets/$id'),
        headers: await _headers(),
      ),
      200,
      (response) => Pet.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      ),
    );
  }

  // POST /pets — создать питомца
  @override
  Future<Result<Pet>> create(Pet pet) {
    return _execute<Pet>(
      () async => http.post(
        Uri.parse('$baseUrl/pets'),
        headers: await _headers(),
        body: jsonEncode(pet.toJson()),
      ),
      201,
      (response) => Pet.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      ),
    );
  }

  // PUT /pets/{id} — обновить питомца
  @override
  Future<Result<Pet>> update(Pet pet) {
    return _execute<Pet>(
      () async => http.put(
        Uri.parse('$baseUrl/pets/${pet.id}'),
        headers: await _headers(),
        body: jsonEncode(pet.toJson()),
      ),
      200,
      (response) => Pet.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      ),
    );
  }

  // DELETE /pets/{id} — удалить питомца
  @override
  Future<Result<void>> delete(int id) async {
    final result = await _execute<http.Response>(
      () async => http.delete(
        Uri.parse('$baseUrl/pets/$id'),
        headers: await _headers(),
      ),
      204,
      (response) => response,
    );

    return switch (result) {
      Ok() => const Ok(null),
      Err(:final msg) => Err(msg),
    };
  }
}

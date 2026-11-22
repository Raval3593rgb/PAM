
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/vet_visit.dart';
import '../api_message.dart';
import '../result.dart';
import '../token_store.dart';
import 'vet_visit_repository.dart';

class HttpVetVisitRepository implements VetVisitRepository {
  HttpVetVisitRepository(
    this.baseUrl,
    this.tokens, {
    this.onUnauthorized,
  });

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  // JWT для защищённых запросов
  Future<Map<String, String>> _headers() async {
    final token = await tokens.read();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Обработка истёкшего JWT
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

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != expectedStatus) {
        return Err(apiMessage(response));
      }

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

  // Преобразование ответа сервера в список посещений
  List<VetVisit> _decodeList(http.Response response) {
    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final items = data['items'] as List<dynamic>;

    return items
        .map(
          (item) => VetVisit.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Преобразование ответа в один объект VetVisit
  VetVisit _decodeVisit(http.Response response) {
    return VetVisit.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // GET /vet-visits
  @override
  Future<Result<List<VetVisit>>> fetchAll() {
    return _execute<List<VetVisit>>(
      () async => http.get(
        Uri.parse('$baseUrl/vet-visits'),
        headers: await _headers(),
      ),
      200,
      _decodeList,
    );
  }

  // GET /vet-visits?petId=2
  @override
  Future<Result<List<VetVisit>>> fetchByPetId(int petId) {
    final uri = Uri.parse('$baseUrl/vet-visits').replace(
      queryParameters: {
        'petId': petId.toString(),
      },
    );

    return _execute<List<VetVisit>>(
      () async => http.get(
        uri,
        headers: await _headers(),
      ),
      200,
      _decodeList,
    );
  }

  // GET /vet-visits/{id}
  @override
  Future<Result<VetVisit>> fetchById(int id) {
    return _execute<VetVisit>(
      () async => http.get(
        Uri.parse('$baseUrl/vet-visits/$id'),
        headers: await _headers(),
      ),
      200,
      _decodeVisit,
    );
  }

  // POST /vet-visits
  @override
  Future<Result<VetVisit>> create(VetVisit visit) {
    return _execute<VetVisit>(
      () async => http.post(
        Uri.parse('$baseUrl/vet-visits'),
        headers: await _headers(),
        body: jsonEncode(visit.toJson()),
      ),
      201,
      _decodeVisit,
    );
  }

  // PUT /vet-visits/{id}
  @override
  Future<Result<VetVisit>> update(VetVisit visit) {
    return _execute<VetVisit>(
      () async => http.put(
        Uri.parse('$baseUrl/vet-visits/${visit.id}'),
        headers: await _headers(),
        body: jsonEncode(visit.toJson()),
      ),
      200,
      _decodeVisit,
    );
  }

  // DELETE /vet-visits/{id}
  @override
  Future<Result<void>> delete(int id) async {
    final result = await _execute<http.Response>(
      () async => http.delete(
        Uri.parse('$baseUrl/vet-visits/$id'),
        headers: await _headers(),
      ),
      204,
      (response) => response,
    );

    return switch (result) {
      Ok() => const Ok<void>(null),
      Err(:final msg) => Err<void>(msg),
    };
  }
}


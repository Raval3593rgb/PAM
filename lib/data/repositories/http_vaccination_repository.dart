
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/vaccination.dart';
import '../api_message.dart';
import '../result.dart';
import '../token_store.dart';
import 'vaccination_repository.dart';

class HttpVaccinationRepository implements VaccinationRepository {
  HttpVaccinationRepository(
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

  // Обработка HTTP 401
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();

    return 'Сессия истекла — войдите снова';
  }

  // Общая обработка GET-запросов
  Future<Result<List<Vaccination>>> _fetch(Uri uri) async {
    try {
      final response = await http
          .get(uri, headers: await _headers())
          .timeout(_timeout);

      if (response.statusCode == 401) {
        return Err(await _sessionDied());
      }

      if (response.statusCode != 200) {
        return Err(apiMessage(response));
      }

      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final items = data['items'] as List<dynamic>;

      final vaccinations = items
          .map(
            (item) => Vaccination.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();

      return Ok(vaccinations);
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

  // GET /vaccinations
  @override
  Future<Result<List<Vaccination>>> fetchAll() {
    return _fetch(
      Uri.parse('$baseUrl/vaccinations'),
    );
  }

  // GET /vaccinations?petId=2
  @override
  Future<Result<List<Vaccination>>> fetchByPetId(int petId) {
    final uri = Uri.parse('$baseUrl/vaccinations').replace(
      queryParameters: {
        'petId': petId.toString(),
      },
    );

    return _fetch(uri);
  }


  @override
  Future<Result<Vaccination>> create(Vaccination vaccination) async {
    try {
      final token = await tokens.read();

      final response = await http.post(
        Uri.parse('$baseUrl/vaccinations'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(vaccination.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 401) {
        await tokens.clear();
        onUnauthorized?.call();
        return const Err<Vaccination>(
          'Сессия истекла. Войдите снова.',
        );
      }

      if (response.statusCode != 201) {
        return Err<Vaccination>(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Ok<Vaccination>(Vaccination.fromJson(data));
    } on TimeoutException {
      return const Err<Vaccination>('Сервер не отвечает');
    } on SocketException {
      return const Err<Vaccination>('Нет сети');
    } on http.ClientException {
      return const Err<Vaccination>('Ошибка соединения');
    } on FormatException {
      return const Err<Vaccination>('Некорректный ответ сервера');
    } catch (_) {
      return const Err<Vaccination>('Не удалось добавить вакцинацию');
    }
  }


  @override
  Future<Result<Vaccination>> update(Vaccination vaccination) async {
    try {
      final token = await tokens.read();

      final response = await http.put(
        Uri.parse('$baseUrl/vaccinations/${vaccination.id}'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(vaccination.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 401) {
        await tokens.clear();
        onUnauthorized?.call();
        return const Err<Vaccination>('Сессия истекла. Войдите снова.');
      }

      if (response.statusCode != 200) {
        return Err<Vaccination>(apiMessage(response));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Ok<Vaccination>(Vaccination.fromJson(data));
    } on TimeoutException {
      return const Err<Vaccination>('Сервер не отвечает');
    } on SocketException {
      return const Err<Vaccination>('Нет сети');
    } on http.ClientException {
      return const Err<Vaccination>('Ошибка соединения');
    } on FormatException {
      return const Err<Vaccination>('Некорректный ответ сервера');
    } catch (_) {
      return const Err<Vaccination>('Не удалось обновить вакцинацию');
    }
  }


  @override
  Future<Result<void>> delete(int id) async {
    try {
      final token = await tokens.read();

      final response = await http.delete(
        Uri.parse('$baseUrl/vaccinations/$id'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
        },
      ).timeout(_timeout);

      if (response.statusCode == 401) {
        await tokens.clear();
        onUnauthorized?.call();
        return const Err<void>('Сессия истекла. Войдите снова.');
      }

      if (response.statusCode != 204) {
        return Err<void>(apiMessage(response));
      }

      return const Ok<void>(null);
    } on TimeoutException {
      return const Err<void>('Сервер не отвечает');
    } on SocketException {
      return const Err<void>('Нет сети');
    } on http.ClientException {
      return const Err<void>('Ошибка соединения');
    } on FormatException {
      return const Err<void>('Некорректный ответ сервера');
    } catch (_) {
      return const Err<void>('Не удалось удалить вакцинацию');
    }
  }
}

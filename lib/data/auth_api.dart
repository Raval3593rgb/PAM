
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class AuthApi {
  AuthApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;

  static const _timeout = Duration(seconds: 8);

  // Регистрация пользователя
  Future<Result<void>> register(
    String email,
    String password,
    String name,
  ) {
    return _post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  // Авторизация пользователя
  Future<Result<void>> login(
    String email,
    String password,
  ) {
    return _post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  // Выход из аккаунта
  Future<void> logout() => tokens.clear();

  // Общий метод HTTP POST
  Future<Result<void>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      // Ошибки HTTP: 400, 401, 409 и другие
      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        return Err(apiMessage(response));
      }

      // Преобразование JSON
      final data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final token = data['token'] as String;

      if (token.isEmpty) {
        return const Err('Сервер вернул пустой токен');
      }

      // Сохраняем JWT
      await tokens.save(token);

      return const Ok(null);

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
}

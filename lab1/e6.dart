Future<String> fetchProfile(String username) async {
  await Future.delayed(const Duration(seconds: 2));

  return 'Профиль: $username, группа TI-231, решено упражнений: 42';
}

Future<void> main() async {
  const username = 'ana.rusu';

  print('Загружается профиль пользователя $username...');

  final profile = await fetchProfile(username);

  print(profile);
  print('Готово.');
}
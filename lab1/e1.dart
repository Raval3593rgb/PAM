int parseOrDefault(String? input, int fallback) {
  return int.tryParse(input ?? '') ?? fallback;
}

void main() {
  print(parseOrDefault('42', 0));
  print(parseOrDefault('abc', 0));
  print(parseOrDefault(null, 7));
  print(parseOrDefault('7.5', -1));
}
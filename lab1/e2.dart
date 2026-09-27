double promotedAverage(List<int> grades) {
  final promoted = grades.where((grade) => grade >= 5).toList();

  if (promoted.isEmpty) {
    return 0.0;
  }

  final sum = promoted.fold<int>(0, (total, grade) => total + grade);

  return sum / promoted.length;
}

void main() {
  print(promotedAverage([9, 4, 7, 10, 3, 5]));
  print(promotedAverage([10, 10, 9]));
  print(promotedAverage([3, 4, 2]));
}
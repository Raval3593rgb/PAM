class Student {
  final String name;
  final String group;

  // Основной конструктор
  Student(this.name, this.group);

  // Именованный конструктор для гостя
  Student.guest()
      : name = 'Guest',
        group = '—';

  @override
  String toString() {
    return 'Student($name, $group)';
  }

  @override
  bool operator ==(Object other) {
    return other is Student &&
        other.name == name &&
        other.group == group;
  }

  @override
  int get hashCode => Object.hash(name, group);
}

void main() {
  print(Student('Ana Rusu', 'TI-231'));
  print(Student.guest());

  print(
    Student('Ana Rusu', 'TI-231') ==
        Student('Ana Rusu', 'TI-231'),
  );

  final students = {
    Student('Ana Rusu', 'TI-231'),
    Student('Ana Rusu', 'TI-231'),
  };

  print(students.length);
}
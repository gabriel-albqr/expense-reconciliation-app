/// Represents a person that participates in shared expenses.
class Person {
  Person({required this.id, required this.name});

  final String id;
  final String name;

  @override
  String toString() => 'Person(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Person && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

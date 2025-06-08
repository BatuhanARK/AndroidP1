// Data model representing a person with a name and phone number.
class Person {
  String name;
  String phone;

  /// Creates a new [Person] instance with the given name and phone.
  Person({required this.name, required this.phone});

  /// Converts this person to a JSON-serializable map (for SharedPreferences, etc.).
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
  };

  /// Factory constructor to create a [Person] instance from a JSON map.
  factory Person.fromJson(Map<String, dynamic> map) => Person(
        name: map['name'],
        phone: map['phone'],
      );
}

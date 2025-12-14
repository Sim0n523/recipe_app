class Meal {
  final String id;
  final String name;
  final String thumbnail;

  Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  // Factory constructor for API JSON response (from TheMealDB API)
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String,
    );
  }

  // Factory constructor for Firestore data
  factory Meal.fromFirestore(Map<String, dynamic> data) {
    return Meal(
      id: data['id'] as String,
      name: data['name'] as String,
      thumbnail: data['thumbnail'] as String,
    );
  }

  // Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
    };
  }

  // Copy with method for creating modified copies
  Meal copyWith({
    String? id,
    String? name,
    String? thumbnail,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
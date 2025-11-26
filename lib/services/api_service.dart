import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';

class ApiService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final res = await http.get(Uri.parse('$_base/categories.php'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body)['categories'] as List;
      return list.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Meal>> fetchMealsByCategory(String category) async {
    final res = await http.get(Uri.parse('$_base/filter.php?c=$category'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body)['meals'] as List?;
      if (list == null) return [];
      return list.map((e) => Meal.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    final res = await http.get(Uri.parse('$_base/search.php?s=$query'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body)['meals'] as List?;
      if (list == null) return [];
      return list.map((e) => Meal.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<MealDetail> fetchMealDetail(String id) async {
    final res = await http.get(Uri.parse('$_base/lookup.php?i=$id'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body)['meals'] as List;
      return MealDetail.fromJson(list.first);
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  Future<MealDetail> fetchRandomMeal() async {
    final res = await http.get(Uri.parse('$_base/random.php'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body)['meals'] as List;
      return MealDetail.fromJson(list.first);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}

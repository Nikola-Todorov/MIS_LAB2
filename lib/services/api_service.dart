import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Fetch all categories
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Category> categories = (data['categories'] as List)
          .map((cat) => Category.fromJson(cat))
          .toList();
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Fetch meals by category
  Future<List<Meal>> fetchMealsByCategory(String category) async {
    final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return [];
      List<Meal> meals = (data['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList();
      return meals;
    } else {
      throw Exception('Failed to load meals');
    }
  }

  // Search meals
  Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null) return [];
      List<Meal> meals = (data['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList();
      return meals;
    } else {
      throw Exception('Failed to search meals');
    }
  }

  // Fetch meal details
  Future<MealDetail> fetchMealDetail(String id) async {
    final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$id')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] == null || data['meals'].isEmpty) {
        throw Exception('Meal not found');
      }
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to load meal details');
    }
  }

  // Fetch random meal
  Future<MealDetail> fetchRandomMeal() async {
    final response = await http.get(
        Uri.parse('$baseUrl/random.php')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
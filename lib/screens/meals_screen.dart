import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../models/meal.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String category;
  final FirebaseService firebaseService;

  const MealsScreen({
    Key? key,
    required this.category,
    required this.firebaseService,
  }) : super(key: key);

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final ApiService api = ApiService();
  late Future<List<Meal>> mealsFuture;
  String query = '';

  @override
  void initState() {
    super.initState();
    mealsFuture = api.fetchMealsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) async {
                setState(() => query = v);
                if (v.trim().isEmpty) {
                  setState(() =>
                  mealsFuture = api.fetchMealsByCategory(widget.category));
                } else {
                  setState(() => mealsFuture = api.searchMeals(v));
                }
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Meal>>(
        future: mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final meals = snapshot.data ?? [];
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return MealCard(
                meal: meal,
                firebaseService: widget.firebaseService,
                onTap: () async {
                  final detail = await api.fetchMealDetail(meal.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailScreen(
                        mealDetail: detail,
                        firebaseService: widget.firebaseService,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
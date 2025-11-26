import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class MealDetailScreen extends StatelessWidget {
  final MealDetail mealDetail;
  MealDetailScreen({required this.mealDetail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mealDetail.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(mealDetail.thumbnail),
            ),
            SizedBox(height: 12),
            Text(mealDetail.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (mealDetail.instructions.isNotEmpty) ...[
              Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(mealDetail.instructions),
              SizedBox(height: 12),
            ],
            if (mealDetail.ingredients.isNotEmpty) ...[
              Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              ...mealDetail.ingredients.map((m) {
                final entry = m.entries.first;
                return Text('- ${entry.key}: ${entry.value}');
              }).toList(),
              SizedBox(height: 12),
            ],
            if (mealDetail.youtube.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final url = mealDetail.youtube;
                  if (await canLaunch(url)) await launch(url);
                },
                icon: Icon(Icons.play_circle_fill),
                label: Text('Watch on YouTube'),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),
          ],
        ),
      ),
    );
  }
}

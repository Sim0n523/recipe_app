import 'package:flutter/material.dart';
import '../models/meal.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(imageUrl: meal.thumbnail, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              meal.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

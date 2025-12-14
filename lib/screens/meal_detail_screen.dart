import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../models/meal.dart';
import '../services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MealDetailScreen extends StatefulWidget {
  final MealDetail mealDetail;
  final FirebaseService firebaseService;

  const MealDetailScreen({
    Key? key,
    required this.mealDetail,
    required this.firebaseService,
  }) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFav = await widget.firebaseService.isFavorite(widget.mealDetail.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await widget.firebaseService.removeFavorite(widget.mealDetail.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed from favorites'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.grey[700],
            ),
          );
        }
      } else {
        // Convert MealDetail to Meal for storing in favorites
        final meal = Meal(
          id: widget.mealDetail.id,
          name: widget.mealDetail.name,
          thumbnail: widget.mealDetail.thumbnail,
        );
        await widget.firebaseService.addFavorite(meal);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to favorites'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealDetail.name),
        actions: [
          _isLoading
              ? Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
              : IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(widget.mealDetail.thumbnail),
            ),
            SizedBox(height: 12),
            Text(
              widget.mealDetail.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (widget.mealDetail.instructions.isNotEmpty) ...[
              Text(
                'Instructions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(widget.mealDetail.instructions),
              SizedBox(height: 12),
            ],
            if (widget.mealDetail.ingredients.isNotEmpty) ...[
              Text(
                'Ingredients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              ...widget.mealDetail.ingredients.map((m) {
                final entry = m.entries.first;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${entry.key}: ${entry.value}'),
                );
              }).toList(),
              SizedBox(height: 12),
            ],
            if (widget.mealDetail.youtube.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = widget.mealDetail.youtube;
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: Icon(Icons.play_circle_fill),
                  label: Text('Watch on YouTube'),
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/categories_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Step 2: Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(RecipeApp(notificationService: notificationService));
}

class RecipeApp extends StatelessWidget {
  final NotificationService? notificationService;

  const RecipeApp({Key? key, this.notificationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
      home: MainScreen(notificationService: notificationService),
    );
  }
}

class MainScreen extends StatefulWidget {
  final NotificationService? notificationService;

  const MainScreen({Key? key, this.notificationService}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();

    // Initialize Firebase service with a user ID
    // TODO: Replace 'user_123' with actual user ID from authentication
    _firebaseService = FirebaseService(userId: 'user_123');

    // Step 3: Schedule daily notification
    // This will trigger every day at 9:00 AM
    _scheduleDailyNotification();
  }

  Future<void> _scheduleDailyNotification() async {
    // Only schedule if notification service is available
    if (widget.notificationService == null) {
      print('NotificationService not available (probably in test mode)');
      return;
    }

    try {
      // Option 1: Schedule with random meal from favorites
      final favoriteMeals = await _firebaseService.getFavoritesList();

      if (favoriteMeals.isNotEmpty) {
        // If user has favorites, use one of them
        await widget.notificationService!.scheduleDailyReminderWithRandomMeal(
          meals: favoriteMeals,
          hour: 9,    // 9:00 AM
          minute: 0,
        );
      } else {
        // If no favorites, just schedule a generic reminder
        await widget.notificationService!.scheduleDailyReminder(
          hour: 9,    // 9:00 AM
          minute: 0,
        );
      }

      print('Daily notification scheduled successfully!');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  List<Widget> get _screens => [
    CategoriesScreen(firebaseService: _firebaseService),
    FavoritesScreen(firebaseService: _firebaseService),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
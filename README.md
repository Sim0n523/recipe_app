# Recipe App

## 1. Project Title

**Recipe App (Flutter + TheMealDB API)**

---

## 2. Short Description

A mobile application built with Flutter that allows users to browse recipes by category, view detailed instructions, and save favorite recipes for quick access.

---

## 3. Demo / Screenshots

<p align="center">
  <img src="screenshots/Screenshot 2025-11-26 193145.png" width="200" alt="Image 1"/>
  <img src="screenshots/Screenshot 2025-11-26 193325.png" width="200" alt="Image 2"/>
  <img src="screenshots/Screenshot 2025-11-26 193425.png" width="200" alt="Image 3"/>
</p>

---

## 4. Features

- Browse recipe categories with a clean and responsive UI
- View detailed recipe information (ingredients, instructions, images)
- Search recipes by name within categories
- Mark and manage favorite recipes 
- View a random recipe of the day

---

## 5. Tech Stack

- **Flutter** (Dart)
- **TheMealDB** REST API
- **HTTP** package
- **Cached Network Image**
- **Material Design** UI

---

## 6. Installation

```bash
git clone https://github.com/your-username/recipe_app.git
cd recipe_app
flutter pub get
flutter run
```

---

## 7. Usage

1. Open the app on an emulator or physical device
2. Browse available recipe categories
3. Tap a category to view meals
4. Select a meal to view full recipe details
5. Tap the heart button to add/remove favorites
6. Open the favorites screen from the top bar


## 8. Project Structure

```

lib/
├── models/        # Data models (Category, Meal, MealDetail)
├── services/      # API logic and Favorites service
├── screens/       # UI screens (Home, Meals, Details, Favorites)
├── widgets/       # Reusable UI components
└── main.dart      # App entry point

```


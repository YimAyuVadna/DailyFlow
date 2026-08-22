# DailyFlow (habitflow)

DailyFlow is a beautiful, gamified, and highly customizable Flutter application designed to help you track habits, maintain streaks, and build long-term consistency.

---

## 🚀 Key Features

* **Interactive Habit Tracker:** Create habits of different types (Yes/No boolean or quantitative targets like ml, pages, steps, minutes). Reorder habits easily via drag-and-drop.
* **Gamification & Leveling:** Complete habits to gain XP and level up. Track a global fire streak that increments as long as you complete at least one habit daily.
* **Achievements & Badges:** Earn up to 19 unique milestone badges (e.g., *First Step*, *Weekend Warrior*, *Overachiever*, *Centurion*, and *Streak Starter*) as you build habits.
* **365-Day Activity Heatmap & Matrix:** A GitHub-style activity grid visualizing your consistency over the last year. Choose between 5 customizable color palettes and toggle a gorgeous glow effect in settings.
* **Home Screen Widgets:** Pin the "Daily Momentum" widget (powered by `home_widget`) to your Android/iOS home screen. Log progress or toggle habit completion directly from the home screen.
* **Local Notifications:** Daily automated reminders to prompt you to log your daily progress and keep streaks alive.
* **Category Tabs & Archiving:** Keep your workspace clean by classifying habits into custom categories, or archiving inactive habits without losing history.
* **Theme Customization:** Seamlessly toggle between dark and light modes with custom-crafted dark UI elements.

---

## 📥 How to Import the Project

### 1. Prerequisites
Ensure you have the following installed on your machine:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `^3.11.0`)
* [Dart SDK](https://dart.dev/get-started) (included automatically with Flutter)
* An IDE with Flutter plugins enabled (e.g., **VS Code**, **Android Studio**, or **IntelliJ IDEA**)

### 2. Import into your IDE
1. Open your IDE.
2. Select **Open Folder** (or **Open Project**) and select the directory where this project is located.
3. If using VS Code or Android Studio, ensure the Flutter and Dart extensions/plugins are installed and active.

### 3. Fetch Dependencies
Open a terminal in the root of the project directory and run the following command to download all necessary pub packages:

```bash
flutter pub get
```

---

## 🏃 How to Run the Application

You can run DailyFlow on Android, iOS, Web, or Desktop (macOS/Windows/Linux).

### 1. Select a Target Device
To see the list of connected devices and emulators:

```bash
flutter devices
```

### 2. Run in Development Mode
To launch the app with hot reload enabled, execute:

```bash
flutter run
```

*Press `r` in the terminal to trigger a **Hot Reload** or `R` to trigger a **Hot Restart**.*

### 3. Build for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ipa --release
```

#### Web
```bash
flutter build web --release
```

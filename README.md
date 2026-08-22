# DailyFlow (habitflow)

DailyFlow is a beautiful, gamified, and highly customizable Flutter application designed to help you track habits, maintain streaks, and build long-term consistency.

---

## 🚀 Key Features

* **Interactive Habit Tracker:** Create habits of different types (Yes/No boolean or quantitative targets like ml, pages, steps, minutes). Reorder habits easily via drag-and-drop.
* **Gamification & Leveling:** Complete habits to gain XP, level up, and maintain a global streak. Complete habits to hear celebratory sound effects!
* **Achievements & Badges:** Earn up to 19 unique milestone badges categorized across five rarity tiers (*Common, Uncommon, Rare, Epic, Legendary*).
* **Interactive Achievement Dialog:** Celebrate milestones with a beautiful, custom-animated achievement popup featuring wiggling confetti particles, XP rewards, and mastery tiers.
* **365-Day Activity Heatmap & Matrix:** A GitHub-style activity grid visualizing consistency over the last year. Choose between 5 customizable color palettes and toggle a gorgeous glow effect.
* **Custom Home & Lock Screen Widgets:** Pin interactive widgets to your Android home or lock screen (powered by `home_widget`). Supports 8 customized widget layouts:
  * **Streak Widget / Lock Streak:** Minimalist tracker to view your current hot streak.
  * **Daily Flow Widget:** Clean progress bar showing your daily habit completion rate.
  * **Quick Focus Widget:** Focus on a specific focal habit and check it off with one tap.
  * **Priority Habits Widget:** Detailed home screen checklist for your top priority habits.
  * **Circadian Widget:** Track habits mapped to daily circadian rhythm phases (morning, afternoon, night).
  * **Master Grid Widget:** View a mini 365-day consistency grid directly on your home screen.
  * **Lock Ring Widget:** Circular circular-progress display for lock screens.
* **Local Notifications:** Automated reminders with rich notifications to keep you on track.
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

# HabitFlow

HabitFlow is a Flutter productivity application focused on personal organization, habit consistency, and performance tracking.

It combines a smart daily planner with an advanced habit tracking system, offering a modern UI and real metrics based on real DateTime calculations.

---

## ✨ Overview

HabitFlow is more than a task list.

It provides:

- 📅 Intelligent daily planning
- 🔁 Advanced habit tracking
- 📊 Real performance metrics
- 🔥 Streak system
- 🌙 Manual light/dark theme toggle
- 🎯 Modern UI with micro-interactions

---

# 🚀 Features

## 📅 Planner

- Dynamic date selection
- Navigate between days (previous / today / next)
- Create and edit tasks
- Custom categories with unique colors
- Circular daily progress indicator
- Navigable monthly calendar
- Full dark mode support
- Animated floating action button (pulse + press effect)

---

## 🔁 Habit System

- Multiple habits support
- Custom selectable active weekdays
- Weekly visual control
- Status states:
    - 🟢 Green → Completed
    - ⚪ Light gray → Not completed
    - ⚫ Dark gray → Not scheduled
- Weekly accuracy calculation
- Monthly accuracy
- Yearly accuracy
- Current streak and best streak
- Interactive monthly calendar
- Real DateTime-based tracking

---

## 🎨 UI / UX

- Material 3 design
- Press animations on buttons
- iOS-style interaction feedback
- Animated progress ring
- Pulsing floating action button
- Manual dark mode toggle with animation
- Consistent surface hierarchy

---

# 🧠 Architecture

Feature-based structure:

lib/
├── core/
│ ├── theme/
│ └── constants/
├── features/
│ ├── habits/
│ │ ├── domain/
│ │ ├── data/
│ │ └── presentation/
│ └── tasks/
│ ├── domain/
│ ├── data/
│ └── presentation/
├── widgets/


### Persistence

- Hive local database
- Typed adapters (Habit / Task)
- Data survives app restarts

---

# 🛠 Tech Stack

- Flutter
- Dart
- Hive
- Material 3
- intl

---

# 📊 Current Project Status

HabitFlow is now an advanced functional MVP featuring:

✔ Persistent storage  
✔ Multi-habit system  
✔ Full task CRUD  
✔ Real performance metrics  
✔ Navigable monthly calendar  
✔ Functional dark mode  
✔ Modern animated UI

---

# 👨‍💻 Author

Manoel Jorge M. Barreto

---

# 📄 License

Developed for educational and technical growth purposes.
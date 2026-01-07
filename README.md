# HISAB - Your Digital Collector

A Flutter-based mobile application for tracking shared expenses and managing settlements between individuals or groups.

![Flutter Version](https://img.shields.io/badge/Flutter-3.35.4-blue)
![Dart Version](https://img.shields.io/badge/Dart-3.9.2-blue)

## 📱 Project Overview

HISAB helps users record, manage, and settle shared expenses efficiently. It provides:

- ✅ Digital expense tracking
- ✅ Transparent expense splitting
- ✅ Real-time balance tracking
- ✅ Group expense management
- ✅ Settlement recording

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                 # Core functionality
│   ├── constants/       # App-wide constants
│   ├── theme/          # App theme configuration
│   ├── utils/          # Utility functions
│   └── config/         # Configuration files
├── domain/             # Business logic layer
│   ├── entities/      # Domain entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business use cases
├── data/              # Data layer
│   ├── models/       # Data models
│   ├── datasources/  # Remote/local data sources
│   └── repositories/ # Repository implementations
└── presentation/      # UI layer
    ├── providers/    # State management
    ├── screens/     # App screens
    └── widgets/     # Reusable widgets
```

## 🎨 Design System

### Color Palette
- **Primary**: Vibrant Purple (#7C3AED) to Blue (#2563EB) gradient
- **Accent**: Pink (#EC4899), Cyan (#06B6D4), Emerald (#10B981)
- **Dark Theme**: Modern dark backgrounds with glassmorphism
- **Light Theme**: Clean light backgrounds

### Typography
- **Headings**: Outfit font (600-700 weight)
- **Body**: Inter font (400-600 weight)

### UI Features
- Gradient buttons with shadow effects
- Glassmorphism cards
- Smooth animations
- Responsive layouts

## 📦 Tech Stack

### Core
- **Flutter** 3.35.4
- **Dart** 3.9.2

### State Management
- **flutter_riverpod** - Modern reactive state management
- **riverpod_annotation** - Code generation for providers

### Backend
- **supabase_flutter** - Backend-as-a-Service
- **Supabase Auth** - Authentication
- **PostgreSQL** - Database with Row Level Security

### Navigation
- **go_router** - Declarative routing

### UI & Assets
- **google_fonts** - Premium typography
- **flutter_svg** - SVG support

### Utilities
- **intl** - Internationalization
- **equatable** - Value equality
- **uuid** - Unique identifiers
- **shared_preferences** - Local storage

## 🗄️ Database Schema

The app uses **Supabase (PostgreSQL)** with the following tables:

1. **users** - User profiles
2. **groups** - Expense sharing groups
3. **group_members** - User-group relationships
4. **categories** - Expense categories
5. **expenses** - Expense records
6. **expense_splits** - How expenses are divided
7. **settlements** - Payment settlements
8. **transactions** - Audit log

All tables have **Row Level Security (RLS)** policies for data protection.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.35.4 or higher
- Dart 3.9.2 or higher
- Android Studio / VS Code with Flutter extensions
- Supabase account (free tier works)

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Set up Supabase**
   - See `supabase_setup_guide.md` for detailed instructions
   - Create a Supabase project
   - Run the SQL migration script from `supabase/migrations/001_initial_schema.sql`
   - Get your project URL and anon key

3. **Configure Supabase credentials**
   - Open `lib/core/config/supabase_config.dart`
   - Replace placeholders with your Supabase credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Key Files

- `lib/main.dart` - App entry point
- `lib/core/constants/app_constants.dart` - App-wide constants
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/presentation/screens/login_screen.dart` - Login UI
- `lib/presentation/screens/register_screen.dart` - Registration UI
- `supabase/migrations/001_initial_schema.sql` - Database schema

## 📱 Features

### Implemented ✅
- Premium dark/light theme with gradient UI
- Authentication screens (Login/Register)
- Custom reusable widgets
- Supabase configuration
- Clean architecture foundation
- Complete database schema with RLS

### Next Steps 🚧
- Complete Supabase setup
- Implement authentication logic
- Build expense management screens
- Add group management
- Implement balance tracking

## 🔒 Security

- Row Level Security (RLS) on all database tables
- Secure authentication with Supabase Auth
- Input validation on all forms
- PKCE authentication flow

## 📄 License

Educational project for lab purposes.

---

**Built with ❤️ using Flutter and Supabase**

# ECHO - Accessibility-Focused Announcement App

ECHO receives live public announcements from a backend, displays them as readable alerts, and personalizes content based on user profile (train, platform, disability flag).

## Features

- Real-time announcement feed
- User profile personalization
- Train & platform filters
- Push notifications
- Accessibility mode (large text, high contrast, TTS)
- Offline caching
- Dark/Light theme
- Multi-language support
- PWD badge indicator
- Voice read-out (TTS)
- Favorites & History

## Setup

```bash
flutter pub get
flutter run
```

**Note:** If platform folders (android/, ios/) are missing, run:
```bash
flutter create . --org com.echo.app --project-name echo
```

## Configuration

### Supabase Auth
Set environment variables or replace in `lib/main.dart`:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anon key

### API Base URL
Set in `lib/core/constants/api_constants.dart`:
- `API_BASE_URL` - Backend API base URL (default: https://api.echo.app)

## Architecture

- **Clean Architecture** + MVVM
- **State Management**: Riverpod
- **Navigation**: go_router

## Project Structure

```
lib/
├── core/           # Constants, themes, utils, router
├── data/           # Models
├── presentation/   # Screens, widgets
├── providers/      # Riverpod state
├── services/       # API, Auth, Cache, Notification, TTS, Connectivity
└── main.dart
```

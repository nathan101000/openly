# 🚪 Openly – Smart Door Access App

Openly is a modern Flutter app that allows users to securely access and control doors. It features token-based authentication, animated door unlocking, and persistent user profiles, all integrated through a clean, user-friendly UI.

## 📱 Features

- 🔐 **Login & Token-based Authentication** (via `auth_service.dart`)
- 🚪 **Secure Door Control** (pulse or timed unlock via `door_service.dart`)
- 🏠 **Home Screen** displaying available doors
- 👤 **User Profile** with session management
- 💚 **Favorites** support (extendable)
- 🌙 **Material Theming** with light/dark support

## 🚀 Getting Started

1. **Install dependencies**

```bash
flutter pub get
```

2. **Run the app**

```bash
flutter run
```

3. **Build for release**

```bash
flutter build apk
```

## 🧪 Notes

- Ensure you provide valid tokens and tenant IDs in `auth_provider`.
- The unlock duration is set to 5 seconds by default (can be customized).
- Designed with expandability for favorite doors, admin features, etc.

## 🎨 Theme

Default primary color: `#4b5c92`
You can customize this via `theme.dart`.

# Modern Mart Keeper

Shop/admin Flutter app for Modern Mart. Manage products, categories, sliders, orders, and send push notifications to customers.

## Features

- **Email/password authentication** — Sign in for shop keepers
- **Product management** — Add, edit, delete products and categories
- **Slider management** — Manage home screen carousel images
- **Order management** — View and update order status
- **Push notifications** — Send order updates to customers (requires backend)

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter |
| Backend | Firebase (Auth, Firestore, Cloud Messaging) |

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio)
- Firebase project (shared with Modern Mart customer app)

## Setup

### 1. Clone and install dependencies

```bash
git clone <repository-url>
cd modern_mart_keeper
flutter pub get
```

### 2. Configure Firebase

**Do not commit** `local.properties`, `google-services.json`, or `GoogleService-Info.plist`.

1. Use the same Firebase project as Modern Mart
2. Add the keeper app (package: `com.fulltimedevs.modern_mart_keeper`)
3. Download `google-services.json` → `android/app/google-services.json`
4. Download `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`

If `google-services.json` was previously committed:

```bash
git rm --cached android/app/google-services.json
```

### 3. Run the app

```bash
flutter run
```

## Push notifications

The FCM **server key must never be in client code**. Use a backend (e.g. Firebase Cloud Functions triggered by Firestore writes) to send notifications. Rotate the key immediately if it was ever committed.

## Security

- API keys and secrets live in gitignored files
- Rotate any keys that were ever committed
- See [SECURING_REPO_KEYS_GUIDE.md](../SECURING_REPO_KEYS_GUIDE.md) in the workspace for a full checklist

## License

Proprietary. All rights reserved.

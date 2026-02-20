# Twitter Clone Frontend (Flutter)

This is the mobile frontend for the Twitter Clone application, built with **Flutter**. It interacts with the Spring Boot backend to provide a rich social media experience.

## 📱 Features

- **Authentication**: Sign Up and Login flows with JWT handling.
- **Home Feed**: View tweets from all users (global feed).
- **Tweeting**: Create and post new tweets.
- **Interactions**: Like, Retweet, and Bookmark tweets. Optimized with optimistic UI updates.
- **Profile**: View user profiles, including their own tweets, bio, and stats.
- **Search**: Search for users and tweets.

## 🛠 Technology Stack

- **Flutter 3.x**
- **Dart**
- **Dio**: For HTTP requests to the backend.
- **Flutter Secure Storage**: For storing JWT tokens securely.
- **Provider / ValueNotifier**: For state management.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Android Studio or VS Code with Flutter extensions.
- An Emulator or Physical Device.

### Installation

1.  **Clone the repository**
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure Backend URL**:
    - Open `lib/core/api_client.dart`.
    - Ensure the `baseUrl` matches your backend's IP/Port.
    - Default is `http://10.0.2.2:8080` for Android Emulator accessing localhost.

4.  **Run the application**:
    ```bash
    flutter run
    ```

## 📂 Project Structure

- `lib/main.dart`: Entry point.
- `lib/screens`: UI Screens (Login, Home, Profile, etc.).
- `lib/services`: Service layer for API calls (TweetService, AuthService, etc.).
- `lib/models`: Data models (Tweet, User, etc.).
- `lib/widgets`: Reusable UI components (TweetCard, Input fields).
- `lib/core`: Core utilities (ApiClient, Navigation).

## ⚠️ Note

Establish a connection to the Backend Service (`twitter-backend`) before running the app to ensure data is fetched correctly.

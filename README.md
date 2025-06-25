# 🟡 KurdWay Taxi App

KurdWay is a modern ride-hailing and bus-tracking application built with **Flutter** and powered by **Firebase**. It enables users to book taxis, monitor live bus locations, and pay via wallet or cash — tailored for the Kurdistan region and beyond.

---

## ✨ Features

* 🚖 **Taxi Booking**: Book rides with real-time tracking and trip details.
* 🚌 **Bus Tracking**: View nearby buses with live location updates.
* 💳 **Wallet System**: Recharge your balance and pay seamlessly.
* 🗜️ **Google Maps Integration**: Real-time location, routes, and directions.
* 🧰 **Admin Panel**: Web & desktop panel to manage rides, users, and transactions.
* 🔐 **OTP Authentication**: Secure login and sign-up using phone verification.
* 🌐 **Multiplatform**: Supports Android, iOS, Web, Windows, Mac, and Linux.

---

## 🛠️ Tech Stack & Packages

### 🔹 Core Flutter Packages

| Feature                    | Package                                                                         |
| -------------------------- | ------------------------------------------------------------------------------- |
| UI                         | `flutter_svg`, `lottie`, `google_fonts`, `eva_icons_flutter`, `cupertino_icons` |
| Animations & Transitions   | `animated_splash_screen`, `page_transition`                                     |
| State Management & Routing | `get`                                                                           |
| Image Handling             | `image_picker`, `image_cropper`, `cached_network_image`                         |
| Input & Auth               | `pin_code_fields`, `fluttertoast`                                               |
| Preferences                | `shared_preferences`, `intl`                                                    |
| App Control                | `restart_app`                                                                   |

### 🔥 Firebase

* `firebase_core`
* `firebase_auth`
* `cloud_firestore`

### 🌍 Location & Maps

* `geolocator`
* `geocoding`
* `google_maps_flutter`
* `flutter_polyline_points`
* `flutter_typeahead`
* `flutter_heat_map`

### 🌐 Network & HTTP

* `dio`
* `http`
* `url_launcher`

### 🔒 Security

* `encrypt`

---

## 🧪 Installation

### 🔧 Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Firebase CLI](https://firebase.google.com/docs/cli)
* Android Studio or VSCode

### 📅 Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/shram0077/kurdway-taxi.git
   cd kurdway-taxi
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase setup**

   * Add `google-services.json` to `android/app/`
   * Add `GoogleService-Info.plist` to `ios/Runner/`
   * Update `firebase_options.dart` (use `flutterfire configure`)

4. **Run the app**

   ```bash
   flutter run
   ```

---

## 🖥️ Admin Panel

The project includes a separate **admin panel** for managing:

* Driver accounts
* Ride history
* Transactions & wallet balances

> The admin panel is cross-platform (Web, Windows, Mac).

---

## 📂 Project Structure (Simplified)

```
lib/
├── Screens/             # UI Screens (Home, Booking, Splash, Auth, etc.)
├── Models/              # Data models like UserModel, CarModel
├── Services/            # Firebase and backend services
├── Utils/               # Reusable widgets, colors, styles
├── Constant/            # App-wide constants (colors, Firebase refs)
└── main.dart            # Entry point
```

---

## 🤝 Contribution

We welcome contributions! You can:

* Submit a pull request
* Open an issue for a bug or feature
* Help translate/localize the app

Please follow standard Flutter best practices and keep code clean & readable.

---

## 📄 License

This project is licensed under the **MIT License**.
Feel free to use it for personal or commercial purposes with attribution.

---

## 📞 Contact

For questions or feedback,
📧 **Email**: [shram0077@gmail.com](mailto:shram0077@gmail.com)
🔗 **GitHub**: [@shram0077](https://github.com/shram0077)

---

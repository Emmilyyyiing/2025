# ಅಂತರ್-ಜಲ Watch — Anthar-Jala Watch

> Community-powered borewell & groundwater monitoring for villages and semi-urban areas.

A Flutter Android app that crowdsources borewell data to generate real-time water stress heatmaps, send alerts when groundwater drops, and guide communities on recharge practices.

---

## Architecture

```
User → Flutter App → Firebase Auth
                   → Firestore (borewells, zones, alerts)
                   → Cloud Functions (zone aggregation, alerts)
                   → Firebase Cloud Messaging (push notifications)
                   ↑
             Google Maps API (heatmap overlay)
```

## Features

| Screen | What it does |
|---|---|
| **Map** | Google Maps with colour-coded zone circles (green/yellow/red) by average borewell depth |
| **Log** | Submit borewell depth, year, yield — location anonymised to 500 m grid |
| **Recharge** | Step-by-step DIY recharge guides with diagrams; community pit tracker |
| **Alerts** | Critical/warning/info notifications; AI-generated weekly recommendations |

---

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/anthar-jala-watch.git
cd anthar-jala-watch
```

### 2. Firebase setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an **Android app** with package name `com.antharjala.watch`
3. Download `google-services.json` → place in `android/app/`
4. Enable **Authentication** (Email/Password)
5. Enable **Cloud Firestore** (start in production mode)
6. Enable **Cloud Messaging**

### 3. Google Maps API key

1. Get a Maps SDK for Android key from [Google Cloud Console](https://console.cloud.google.com)
2. Enable **Maps SDK for Android** and **Maps JavaScript API**
3. Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_MAPS_API_KEY"/>
```

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Deploy Firestore rules

```bash
firebase deploy --only firestore:rules
```

### 6. Deploy Cloud Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 7. Run the app

```bash
flutter run
```

---

## Firestore data model

```
/users/{uid}
  name, email, village, createdAt, borewellCount

/borewells/{id}
  userId, depthFt, yearDrilled, yield, currentWaterLevelFt
  anonymisedLocation (GeoPoint — snapped to 500m grid)
  zoneId, notes, createdAt

/zones/{zoneId}
  zoneName, center (GeoPoint), avgDepthFt
  totalBorewells, criticalCount, stressScore (0–1)
  lastUpdated

/alerts/{id}
  zoneId, zoneName, severity (info|warning|critical)
  title, message, createdAt, isRead
```

---

## Heatmap logic

- User's GPS is **snapped to nearest 0.005° grid cell** (~500 m) before storage — exact house location is never recorded.
- Each grid cell = one `zone` document.
- `stressScore = avgDepthFt / 500`, clamped 0–1.
- Map circles are coloured: **green** (< 0.2), **yellow** (0.2–0.5), **red** (> 0.5).
- Cloud Function recalculates zone aggregates on every new borewell entry.

---

## Project structure

```
lib/
  main.dart
  models/
    borewell_entry.dart
    water_alert.dart
  screens/
    splash_screen.dart
    home_screen.dart
    auth/
      login_screen.dart
      register_screen.dart
    tabs/
      map_tab.dart
      log_tab.dart
      recharge_tab.dart
      alerts_tab.dart
  services/
    auth_service.dart
    borewell_service.dart
    notification_service.dart
  widgets/
    water_depth_scale.dart
  utils/
    app_theme.dart
functions/
  index.js          ← Cloud Functions (zone aggregation, alerts)
firestore.rules
pubspec.yaml
```

---

## Contributing

Pull requests welcome. For major changes please open an issue first.

Built for MindMatrix VTU Internship Program — Project #76.

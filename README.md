# 🚍 Pamasahe — Davao City Commuter Companion & Fare Tracker

A modern, cross-platform public transit companion, route notebook, and statutory concession fare calculator built for Davao City commuters with **Flutter** and **Dart**.

---

## 🌟 Key Features

### 1. 📊 Commute Dashboard & Spending Analytics
- **7-Day Spending Bar Chart**: Visual breakdown of daily public transit expenses.
- **Weekly Fare Total**: Tracks spending against commuter weekly budgets.
- **Recent Trips Log**: Quick-access history with fare amounts and transit modes.
- **Quick-Log Action**: Log trips with a single tap.

### 2. 📖 Route Notebook & Multi-Step Planner
- **Multi-Step Commute Routes**: Chain multiple transit rides (e.g. Jeepney $\rightarrow$ Modern PUV $\rightarrow$ Walking) with cumulative fare and duration.
- **Return Trip Reversal**: Automatically generate reverse return routes with swapped origins, destinations, and step sequences.
- **Route Comparison**: Compare saved routes side-by-side by cost (Cheapest) and travel time (Fastest).

### 3. 🚌 Davao City Transit Lines Directory
- **Authentic Local Routes**: Catalogs iconic Davao City transit lines (Toril, Matina Crossing, Ecoland, Buhangin, Lanang, Bankerohan, Sasa, Calinan, Mintal).
- **Interactive Waypoint Fare Matrix**: Select Stop A and Stop B along any route to instantly calculate the regulated segment fare.
- **Vehicle Type Filtering**: Easily filter by Traditional Jeepney, Modern PUV (Blue Bus), or City Bus.
- **Use Line in Route**: Import catalog lines directly into your personal routes.

### 4. 🏷️ Statutory Concession Discount Engine
- **Full Legal Compliance**: Accurately implements 20% statutory fare discounts under Philippine laws:
  - **Republic Act No. 11314** — Student Fare Discount Act
  - **Republic Act No. 9994** — Expanded Senior Citizens Act
  - **Republic Act No. 10754** — Act Expanding the Benefits and Privileges of PWDs
- **Dynamic Application**: Toggle discounts globally across routes, fare matrices, and logged expenses.

### 5. 📍 Google Maps-Style Location Pinning (OpenStreetMap)
- **Full-Bleed Slippy Map Canvas**: High-performance slippy map powered by official, high-resolution OpenStreetMap tiles.
- **Shopee / Foodpanda Style Center Pin**: Floating teardrop pin with smooth dynamic shadow and category badge.
- **Davao Transit Hub Shortcuts**: One-tap shortcuts to popular transfer points (Downtown Roxas, Matina Crossing, SM Ecoland, Bankerohan Market, Abreeza Bajada, Airport, Sasa Wharf, Toril Terminal).
- **Multiple Map Layers**: Switch seamlessly between OpenStreetMap Full Detail, Esri Detailed Street Map, and Clean Light Gray.
- **Real-Time Coordinates & Address Resolution**: Live geographic coordinate calculation and commuter zone categorization.

---

## 🏗️ Architecture & Project Structure

```text
pamasahe/
├── lib/
│   ├── main.dart                          # App entrypoint & initial routing
│   ├── models/                            # Data models
│   │   ├── commute_route.dart             # Commute routes and steps
│   │   ├── saved_place.dart               # Pinned places & categories
│   │   ├── transit_line.dart              # Transport line catalog & stops
│   │   └── trip_log.dart                  # Trip logs & expense tracking
│   ├── screens/                           # UI Screens & Tabs
│   │   ├── home/                          # Dashboard & analytics
│   │   ├── routes/                        # Route notebook & creation
│   │   ├── transit/                       # Transit line catalog & waypoint fare
│   │   ├── history/                       # Trip history & logs
│   │   └── settings/                      # Concession discounts & map place picker
│   │       └── map_place_picker_screen.dart # Google Maps layout with OSM tiles
│   ├── state/                             # App-wide state management
│   │   ├── app_scope.dart                 # Scoped state provider
│   │   └── app_state.dart                 # Central state store & business logic
│   ├── theme/                             # Design tokens & color system
│   │   └── app_colors.dart
│   └── widgets/                           # Reusable UI components
├── test/                                  # Unit & widget tests (100% passing)
│   ├── pamasahe_test.dart
│   └── widget_test.dart
├── Pamasahe.drawio                        # Complete UML Use-Case Diagram
├── USE_CASE_DIAGRAM.md                    # Diagram specifications & Mermaid code
├── PROJECT_SUMMARY.md                     # Academic project summary & requirements
└── pubspec.yaml                           # Flutter dependencies
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `^3.5.0` or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Chrome / Edge (for Web) or Android Studio / VS Code (for Mobile)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/itskyanne/Pamasahe.git
   cd Pamasahe
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the test suite**:
   ```bash
   flutter test
   ```

4. **Launch the application**:
   ```bash
   # Run in Chrome (Web)
   flutter run -d chrome

   # Or run on Android emulator / physical device
   flutter run -d android
   ```

---

## 🧪 Testing

Pamasahe includes comprehensive unit and widget tests covering:
- Concession discount calculations (20% for Student, Senior, PWD)
- Route reversal logic (swapping stops, reversing steps)
- Dynamic trip logging and weekly budget calculations
- Saved places management & coordinate pinning
- Transport line catalog navigation

To execute tests:
```bash
flutter test
```

---

## 📄 Documentation

- [Use-Case Diagram & Specifications](USE_CASE_DIAGRAM.md)
- [Project Summary & Use-Case Descriptions](PROJECT_SUMMARY.md)
- [UML Draw.io File](Pamasahe.drawio) (can be opened directly on [app.diagrams.net](https://app.diagrams.net))

---

## 👥 Authors & Academic Attribution
- **Course**: CCE 106
- **Year & Term**: 3rd Year, 1st Semester, 2nd Term
- **Institution**: University of Mindanao

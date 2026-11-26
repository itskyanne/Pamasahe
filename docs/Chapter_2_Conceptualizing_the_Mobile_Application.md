# CHAPTER 2: CONCEPTUALIZING THE MOBILE APPLICATION

**Course:** CCE 106 — Mobile Application Development  
**Academic Level:** 3rd Year, 1st Semester (2nd Term)  
**Project Title:** Pamasahe — Davao City Commuter Companion & Fare Tracker  
**Platform:** Flutter / Dart (Cross-Platform Mobile Application)  

---

## VI. Wireframes

Wireframing establishes the architectural blueprint, visual hierarchy, user interface components, and operational interaction flows for **Pamasahe**. The interface follows modern Material 3 design guidelines customized for mobile transit operations in Davao City. Below are the annotated structural wireframes representing all primary screens of the application, emphasizing the Commute Dashboard and the core transactional engines.

### 1. Commute Dashboard (`HomeTab`)
```text
+-------------------------------------------------------------+
|  PAMASAHE                    [🔔 Reminders ON] [👤 Profile] |
+-------------------------------------------------------------+
|  Magandang umaga, Dwayne!                     Monday, Nov 9 |
|                                                             |
|  +-- WEEKLY COMMUTE EXPENSE CARD ------------------------+  |
|  |  SPENT THIS WEEK:                 ₱ 89.60             |  |
|  |  Budget: ₱ 150.00          [=====>.......] (59.7%)    |  |
|  |  Statutory Discount: [●] 20% Student Concession Active|  |
|  |                                                       |  |
|  |  DAILY BREAKDOWN (7-Day Bar Chart):                   |  |
|  |   ₱40|        █                                       |  |
|  |   ₱20|   █    █    █                                  |  |
|  |    ₱0+---+----+----+----+----+----+----+              |  |
|  |       M    T    W    T    F    S    S                 |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [⚡ QUICK LOG TRIP]       [📊 Detailed Spending Analytics]  |
|                                                             |
|  +-- RECENT COMMUTES ------------------------------------+  |
|  |  🚌 Home to UM Matina Campus          ₱ 26.40  (Today)|  |
|  |     Jeepney -> Modern PUV -> Walk                        |  |
|  |  🛺 School to SM Ecoland              ₱ 10.40  (Nov 8)|  |
|  |     Tricycle Direct                                   |  |
|  |  🚌 Mall to Home (Return)             ₱ 26.40  (Nov 7)|  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ 🏠 Home ] [ 🗺️ Routes ] [ 🚌 Lines ] [ 🕒 History ] [ ⚙️ ]|
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Top App Bar & Header:** Displays brand wordmark, notification reminder status, and user avatar profile access.
* **Weekly Expense & Budget Card:** Features high-contrast cumulative fare total (₱89.60), linear budget utilization gauge (59.7% of ₱150 budget), and concession badge.
* **7-Day Spending Bar Chart:** Mathematical container-based bars visualizing daily expenditures from Monday to Sunday.
* **Action Triggers:** 'Quick Log Trip' primary button dispatches instant modal logger; secondary button opens detailed spending breakdown.
* **Recent Trips Feed:** Displays latest 3 logged trips with transit mode icons, route titles, timestamps, and amounts paid.
* **Floating Persistent Navigation Bar:** Houses 5 primary tabs (Home, Routes, Lines, History, Settings) backed by an `IndexedStack`.

---

### 2. Main Transaction Page A: Route Builder Form (`AddEditRouteScreen`)
```text
+-------------------------------------------------------------+
|  [< Back]               CREATE NEW ROUTE            [💾 Save] |
+-------------------------------------------------------------+
|  Route Name:                                                |
|  [ Home to UM Matina Campus                               ] |
|                                                             |
|  From Place:                         To Place:              |
|  [ 📍 Toril Terminal       v ]       [ 📍 UM Matina Gate  v ]|
|                                                             |
|  Est. Travel Time:                                          |
|  [ 45 ] Minutes                                             |
|                                                             |
|  +-- MULTI-STEP ROUTE TRANSIT LEGS ----------------------+  |
|  | Step 1:                               [ 🗑️ Delete Step ] |  |
|  | Ride Mode: [ 🛺 Tricycle ]                               |  |
|  | Boarding Point: [ St. Jude Phase 2 Neighborhood Gate   ] |  |
|  | Segment Fare:   [ ₱ 10.00 ]                              |  |
|  +-------------------------------------------------------+  |
|  | Step 2:                               [ 🗑️ Delete Step ] |  |
|  | Ride Mode: [ 🚌 Modern PUV (Blue Bus) ]                  |  |
|  | Boarding Point: [ Toril Highway Transfer Terminal      ] |  |
|  | Segment Fare:   [ ₱ 23.00 ]                              |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ + ADD TRANSIT STEP ]                                     |
|                                                             |
|  +-- COMPUTED FARE SUMMARY ------------------------------+  |
|  | Base Cumulative Fare:              ₱ 33.00               |  |
|  | 20% Concession Discount:          -₱  6.60               |  |
|  | TOTAL PAYABLE FARE:                ₱ 26.40               |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Navigation Top Bar:** Back action returns to routes list with unsaved confirmation; Save icon validates and commits data.
* **Origin & Destination Pickers:** Dropdown menus linked to saved place anchors with fast access to the map place picker.
* **Dynamic Multi-Step Container:** Collapsible cards for each transit leg allowing custom `RideType` selection, boarding landmark entry, and individual fares.
* **Step Deletion & Addition:** One-tap removal per step; 'Add Transit Step' appends a new leg and scrolls viewport.
* **Live Concession Summary:** Real-time mathematical aggregation updating base total, statutory 20% discount, and final student fare.

---

### 3. Main Transaction Page B: Commute Trip Logger (`LogTripScreen`)
```text
+-------------------------------------------------------------+
|  [ Cancel ]                 LOG COMMUTE TRIP         [ Done ]|
+-------------------------------------------------------------+
|  SELECT SAVED ROUTE:                                        |
|  [ 🚌 Home to UM Matina Campus (3 Steps)                  v ]|
|                                                             |
|  TRIP DETAILS:                                              |
|  Trip Date:                                                 |
|  [ 📅 Today - Monday, November 9, 2026                 [Pick]|
|                                                             |
|  Amount Paid (₱):                                           |
|  [ 26.40                                                   ] |
|  * Pre-filled with active 20% Student Concession fare.      |
|                                                             |
|  Note / Commute Tag (Optional):                             |
|  [ Morning class rush hour; light rain at Matina crossing  ] |
|                                                             |
|  +-- TRANSACTION PREVIEW --------------------------------+  |
|  | Route:         Home to UM Matina Campus               |  |
|  | Current Week:  ₱ 89.60 -> Updated to: ₱ 116.00        |  |
|  | Remaining:     ₱ 34.00 of ₱ 150.00 Weekly Budget      |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [                  CONFIRM & RECORD TRIP                   ]|
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Route Selection Picker:** Selects existing route; automatically pulls cached fare and calculates concession rate.
* **Date Picker Field:** Defaults to today's date with Cupertino/Material date picker integration; prevents future dating.
* **Amount Paid Input Field:** Allows manual fare override if detours, traffic charges, or price increases occurred.
* **Budget Impact Live Preview:** Calculates immediate impact on weekly allowance before the commuter taps confirm.
* **Confirmation Action:** Commits immutable copy-on-write trip record to local database and displays banner feedback.

---

### 4. Route Notebook Tab (`RoutesTab`)
```text
+-------------------------------------------------------------+
|  PAMASAHE                    [ + Add Route ] [ 🔍 Search ]  |
+-------------------------------------------------------------+
|  YOUR COMMUTE                                               |
|  Your regular routes                       4 Saved Routes   |
|  [ 🔍 Search saved routes...                              ] |
|                                                             |
|  +-- ROUTE CARD 1 ---------------------------------------+  |
|  |  🚌 Home to UM Matina Campus           ₱ 26.40 (Reg ₱33) |  |
|  |  From: Toril Terminal    To: UM Matina Gate              |  |
|  |  Duration: 45 mins       Steps: 3 Legs                   |  |
|  |  Updated: Nov 6, 2026    [ 🔀 Reverse ] [ ⚡ Log Trip ]  |  |
|  +-------------------------------------------------------+  |
|  |  🛺 School to SM Ecoland               ₱ 10.40 (Reg ₱13) |  |
|  |  From: UM Matina         To: SM City Ecoland             |  |
|  |  Duration: 15 mins       Steps: 1 Leg (Tricycle)         |  |
|  |  [ 🔀 Reverse ] [ ⚡ Log Trip ]                           |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ ⚖️ COMPARE SAVED ROUTES (Cheapest vs Fastest)           ]  |
|                                                             |
|  [ 🏠 Home ] [ 🗺️ Routes ] [ 🚌 Lines ] [ 🕒 History ] [ ⚙️ ]|
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Live Search Bar:** Instant filtering by keyword across route names, origins, and destinations with clear action.
* **Route Item Cards:** Summarizes commute details, leg counts, travel time, and dual fare displays (discounted vs regular).
* **One-Tap Inline Reverse Action:** Invokes the route reversal engine to instantly build the return trip with inverted steps.
* **Compare Routes Button:** Opens the route comparator view to evaluate travel alternatives side-by-side.

---

### 5. Route Detail & Timeline Screen (`RouteDetailScreen`)
```text
+-------------------------------------------------------------+
|  [< Routes]             ROUTE DETAILS            [ ✏️ Edit ] |
+-------------------------------------------------------------+
|  Home to UM Matina Campus                                   |
|  From: Toril Terminal             To: UM Matina Campus Gate |
|  Est. Travel Time: 45 mins        Last Updated: Nov 6, 2026 |
|                                                             |
|  +-- COMMUTE TIMELINE BREAKDOWN -------------------------+  |
|  |  (O) Start: Toril Neighborhood                           |  |
|  |   |   🛺 Tricycle (Neighborhood to Highway)    ₱ 10.00  |  |
|  |  (*) Stop 1: Toril Highway Crossing                      |  |
|  |   |   🚌 Modern PUV (Toril -> Matina)          ₱ 23.00  |  |
|  |  (*) Stop 2: Matina Crossing Overpass                    |  |
|  |   |   🚶 Walking / Transfer                    ₱  0.00  |  |
|  |  (X) Destination: University of Mindanao Gate            |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  Regular Fare Total:               ₱ 33.00                  |
|  Student Concession Total (20%):   ₱ 26.40  (Save ₱ 6.60)   |
|                                                             |
|  [ 🔀 REVERSE THIS ROUTE ]          [ ⚡ LOG THIS COMMUTE ] |
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Header & Status:** Shows route nomenclature, endpoint anchors, duration, and fare freshness timestamp.
* **Vertical Waypoint Timeline:** Visual node indicators and connecting lines illustrating step sequences and modes.
* **Dual Tariff Presentation:** Displays full legal breakdown: regular base total, 20% statutory concession, and savings.
* **Action Bar:** Primary actions to clone/reverse route or immediately log trip into the spending history.

---

### 6. Davao City Transit Lines Directory (`LinesTab`)
```text
+-------------------------------------------------------------+
|  PAMASAHE                   DAVAO TRANSIT LINES DIRECTORY   |
+-------------------------------------------------------------+
|  PUBLIC TRANSPORT REFERENCE CATALOG                         |
|  Browse official Davao routes & waypoint fare matrices      |
|                                                             |
|  [ Filter: (●) All   ( ) Jeepney   ( ) Modern PUV   ( ) Bus ]|
|  [ 🔍 Search lines by code, name, or street...            ] |
|                                                             |
|  +-- TRANSIT LINE CARD 1 --------------------------------+  |
|  |  [J02] Route 02: Matina – Downtown Poblacion            |  |
|  |  Type: Traditional PUJ            Fare: ₱ 13.00 (Base)   |  |
|  |  Waypoints: Ulas -> Matina -> Bankerohan -> San Pedro   |  |
|  +-------------------------------------------------------+  |
|  |  [B08] Route 08: Toril Express – Roxas Night Market      |  |
|  |  Type: Modern PUV (Blue Bus)      Fare: ₱ 15.00 (Base)   |  |
|  |  Waypoints: Toril -> Puan -> Bangkal -> Matina -> Roxas  |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ 🏠 Home ] [ 🗺️ Routes ] [ 🚌 Lines ] [ 🕒 History ] [ ⚙️ ]|
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Vehicle Filter Segment Chips:** Rapid filtering across Traditional PUJ, Modern PUV, and City Bus classifications.
* **Catalog Search Field:** Query filtering matching route codes (e.g., J02, B08), terminus names, or intermediate streets.
* **Transit Line Cards:** Summarizes official vehicle types, base regulated tariffs, and key intermediate corridors.

---

### 7. Line Detail & Waypoint Fare Matrix Screen (`LineDetailScreen`)
```text
+-------------------------------------------------------------+
|  [< Lines]              ROUTE 08: TORIL EXPRESS             |
+-------------------------------------------------------------+
|  Vehicle: Modern PUV (Blue Bus)      Service Interval: 8 min|
|  Terminal A: Toril Central           Terminal B: Roxas Ave  |
|                                                             |
|  INTERACTIVE WAYPOINT FARE MATRIX CALCULATOR:               |
|  Tap Stop A (Origin) and Stop B (Destination) to calculate: |
|                                                             |
|  +-- ROUTE STOPS TIMELINE -------------------------------+  |
|  |  [A] Toril Central Terminal              (Selected Point)|  |
|  |   |  Distance from origin: 0.0 km                        |  |
|  |  ( ) Puan Highway Transfer                               |  |
|  |   |  Distance from origin: 4.2 km                        |  |
|  |  ( ) Bangkal Central Market                              |  |
|  |   |  Distance from origin: 7.8 km                        |  |
|  |  [B] Matina Crossing Overpass            (Selected Point)|  |
|  |   |  Distance from origin: 10.5 km                       |  |
|  |  ( ) Bankerohan Bridge Terminal                          |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  CALCULATED SEGMENT FARE (Toril -> Matina Crossing):        |
|  Segment Distance: 10.5 km           Base Tariff: ₱ 23.00   |
|  Student / Concession Fare (20%):    ₱ 18.40  (Save ₱ 4.60) |
|                                                             |
|  [               USE SEGMENT IN CUSTOM ROUTE                ]|
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Line Operational Metadata:** Displays transit line schedule, headways, vehicle type, and terminal endpoints.
* **Interactive Waypoint Selector:** Tap-to-select A/B nodes along the timeline with dynamic segment distance calculation.
* **Segment Fare Matrix Engine:** Computes exact statutory segment tariffs according to LTFRB distance formulas.
* **Use in Custom Route:** Exports selected segment directly into the route builder as a pre-filled transit leg.

---

### 8. Trip History & Spending Analytics (`HistoryTab`)
```text
+-------------------------------------------------------------+
|  PAMASAHE                    TRIP LOG & HISTORY             |
+-------------------------------------------------------------+
|  [ Filter: (●) This Month     ( ) This Week     ( ) Custom ]|
|                                                             |
|  +-- FINANCIAL SUMMARY TILES ----------------------------+  |
|  | TOTAL SPENT        TOTAL TRIPS         CONCESSION SAVED  |  |
|  | ₱ 386.80           18 Commutes         ₱ 96.70 (Saved)   |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ 📄 Export Trip History as CSV ]     [ 🗑️ Clear History ]  |
|                                                             |
|  +-- CHRONOLOGICAL TRIP ENTRIES -------------------------+  |
|  |  Monday, November 9, 2026                                |  |
|  |  🚌 Home to UM Matina Campus              ₱ 26.40  07:30|  |
|  |     (Swipe left to delete)                               |  |
|  +-------------------------------------------------------+  |
|  |  Sunday, November 8, 2026                                |  |
|  |  🛺 School to SM Ecoland                  ₱ 10.40  16:15|  |
|  |  🚌 Mall to Home (Return)                 ₱ 26.40  19:40|  |
|  +-------------------------------------------------------+  |
|                                                             |
|  [ 🏠 Home ] [ 🗺️ Routes ] [ 🚌 Lines ] [ 🕒 History ] [ ⚙️ ]|
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Period Filter Selector:** Instant aggregation toggling between monthly and weekly historical expense scopes.
* **Summary KPI Tiles:** Highlights total expenditure, total rides, and cumulative concession pesos saved.
* **CSV Data Export Button:** Serializes local database records into CSV text copied to clipboard for spreadsheet analysis.
* **Dismissible Trip Items:** Swipe-to-delete gesture items with background deletion prompts and undo capabilities.

---

### 9. Settings & Preferences Tab (`SettingsTab`)
```text
+-------------------------------------------------------------+
|  PAMASAHE                    SETTINGS & COMMUTE PREFERENCES |
+-------------------------------------------------------------+
|  +-- COMMUTER PROFILE CARD ------------------------------+  |
|  |  [👤 DP] Dwayne Paulino                                  |  |
|  |          Student commuter · Member since 2026            |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  FARES & STATUTORY CONCESSIONS:                             |
|  Concession Discount Type:                                  |
|  [ (●) Student (RA 11314)   ( ) Senior (RA 9994)   ( ) PWD ]|
|                                                             |
|  BUDGET THRESHOLDS:                                         |
|  Weekly Commute Budget:     [ ₱ 150.00                    ] |
|  Monthly Commute Budget:    [ ₱ 600.00                    ] |
|                                                             |
|  SAVED COMMUTE PLACES & ANCHORS:                            |
|  * 🏠 Home: Toril District, Davao City                      |
|  * 🏫 School: University of Mindanao Matina Campus          |
|  * 🏬 Mall: SM City Davao (Ecoland)                         |
|  [ 📍 Pin New Place on Map (OpenStreetMap)                ] |
|                                                             |
|  NOTIFICATIONS:                                             |
|  Trip Reminders: [ON ]             Weekly Summary: [OFF]    |
|                                                             |
|  [ 🏠 Home ] [ 🗺️ Routes ] [ 🚌 Lines ] [ 🕒 History ] [ ⚙️ ]|
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Profile & Identity Card:** Displays commuter credentials, account subtitle, and edit profile dialogue.
* **Statutory Concession Radio Selector:** Switches legal concession category between Student (RA 11314), Senior (RA 9994), and PWD (RA 10754).
* **Allowance Threshold Inputs:** Defines weekly and monthly financial budgets used to render progress meters and alert states.
* **Saved Places Manager:** Displays saved geographic origins/destinations with shortcut to the interactive map place picker.

---

### 10. Interactive Draggable Map Place Picker (`MapPlacePickerScreen`)
```text
+-------------------------------------------------------------+
|  [< Back]             PIN PLACE ON DAVAO MAP        [ Layers v]
+-------------------------------------------------------------+
|  +-------------------------------------------------------+  |
|  |     [ OSM Full Detail ] [ Esri Street ] [ Clean Gray ]|  |
|  |                                                       |  |
|  |              +-------------------------+              |  |
|  |              | 🏫 University of        |              |  |
|  |              |    Mindanao Matina      |              |  |
|  |              +------------v------------+              |  |
|  |                           📍                          |  |
|  |                     (CENTER PIN)                      |  |
|  |                     [● Drag Map]                      |  |
|  |                                                       |  |
|  |   [+] Zoom In                                         |  |
|  |   [-] Zoom Out             [🎯 Locate Me]             |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  DAVAO TRANSIT HUB SHORTCUTS:                               |
|  [ UM Matina ] [ SM Ecoland ] [ Bankerohan ] [ Toril Term ]  |
|                                                             |
|  +-- CONFIRM PINNED LOCATION ----------------------------+  |
|  | Place Name:    [ University of Mindanao - Matina Gate ]  |  |
|  | Category:      [ 🏫 School                           v]  |  |
|  | Address:       McArthur Highway, Matina, Davao City      |  |
|  | Coordinates:   7.0585° N, 125.5890° E                    |  |
|  | [                  SAVE PINNED PLACE                  ]  |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Slippy Map Canvas & Layer Controls:** Interactive draggable OpenStreetMap canvas with layer switching between OSM, Esri, and Clean Light styles.
* **Center Teardrop Pin & Speech Bubble:** Fixed center pin with dynamic reverse-geocoded landmark label updating as map pans.
* **Davao Transit Hub Quick Chips:** One-tap presets centering viewport over major transfer hubs (UM Matina, SM Ecoland, Bankerohan, Toril).
* **Sliding Location Confirmation Sheet:** Form editor capturing place name, category tag (Home, School, Mall, Terminal), and verified GPS coordinates.

---

### 11. Supabase Cloud Authentication Screen (`AuthScreen`)
```text
+-------------------------------------------------------------+
|  [< Close]             SUPABASE CLOUD AUTH         [ Offline ]|
+-------------------------------------------------------------+
|                                                             |
|                   ☁️ PAMASAHE CLOUD SYNC                     |
|         Back up routes, sync places & join community        |
|                                                             |
|  +-------------------------------------------------------+  |
|  |  [ G ]   Continue with Google                         |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  ------------------- or email & password ------------------  |
|                                                             |
|  [ Sign In ]                     [ Create Account (Active) ] |
|                                                             |
|  Full Name:       [ Dwayne Paulino                        ] |
|  Student Email:   [ dwayne.paulino@addu.edu.ph            ] |
|  Password:        [ **********                            ] |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [🔒] Create Account & Connect Supabase                 |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  🔒 256-bit Encrypted PostgreSQL with Row-Level Security     |
|  💡 Offline Mode: App functions 100% without cloud login    |
|                                                             |
|  [ Continue in Guest / Offline Mode                         ] |
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Google OAuth 2.0 Integration:** Direct one-tap single sign-on (SSO) authenticating commuters using their institutional or personal Google credentials.
* **Email / Password Authentication:** Form supporting student account creation and credentialed login with client-side validation.
* **Row-Level Security Notice:** Transparent security notice informing users that cloud data is protected by strict PostgreSQL RLS rules where each student only accesses their own records.
* **Offline Fallback Button:** Allows students without internet or active accounts to continue experiencing 100% of the app's features locally.

---

### 12. Community Routes & Crowdsourced Transit Hub (`CommunityRoutesScreen`)
```text
+-------------------------------------------------------------+
|  [< Back]            DAVAO COMMUNITY ROUTES         [ Share ]|
+-------------------------------------------------------------+
|  COMMUNITY TRANSIT REPOSITORY                               |
|  Explore popular crowdsourced student routes in Davao City  |
|                                                             |
|  [ All Routes ]   [ Toril ]   [ Matina ]   [ Buhangin ]   v  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | ⚡ Popular (142 Likes)             42 min • ₱ 38.00    |  |
|  | Toril Terminal to Ateneo Roxas Express                |  |
|  | By: Dwayne (Student) • Shared 2 days ago              |  |
|  | ----------------------------------------------------- |  |
|  | 🚌 Modern PUV (Toril Central -> Roxas Ave)   ₱ 25.00  |  |
|  | 🛺 Tricycle (Roxas Gate -> Finster Hall)      ₱ 13.00  |  |
|  | ----------------------------------------------------- |  |
|  | [ ❤️ Like (142) ]              [ 📥 Import to My Routes ] |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | ⭐ Recommended (98 Likes)           35 min • ₱ 28.00    |  |
|  | Matina Crossing to Abreeza via Bajada                 |  |
|  | By: Sarah M. (Student) • Shared 5 days ago            |  |
|  | [ ❤️ Like (98) ]               [ 📥 Import to My Routes ] |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

#### Annotations & Component Breakdown:
* **Community Transit Feed:** Cloud-connected feed rendering verified multi-step transit routes shared by Davao City student commuters.
* **Route Steps Breakdown:** Displays each segment vehicle type (Modern PUV, Traditional Jeepney, Tricycle), waypoint span, and regulated fares.
* **1-Tap Route Import Button:** Duplicates the community transit path into the commuter's personal Route Notebook, assigning unique local IDs for customized editing.
* **Share My Route Modal:** Commuters can publish their favorite saved commute routes to the cloud repository with their commuter name.

---

## VII. Task Analysis

Task analysis models the cognitive and operational journey of commuters executing primary application workflows. The following hierarchical task analyses (HTA) detail the sequential user journey for the two main transactional operations: (1) Assembling and Saving a Multi-Step Commute Route, and (2) Quick-Logging a Completed Commute Trip.

### Task Journey 1: Assembling and Saving a Multi-Step Commute Route
* **Goal:** A student commuter creates and records a daily 3-leg journey from their boarding residence in Toril to the University of Mindanao Matina campus, verifying statutory concession pricing and saving it into their permanent route notebook.
* **Step 1 (Initiation):** The commuter opens Pamasahe and reviews the Dashboard overview, then taps the 'Routes' icon on the floating navigation bar (or taps '+ Add Route' on the top bar).
* **Step 2 (Configuration):** The application transitions to the Route Builder form (`AddEditRouteScreen`). The commuter enters "Home to UM Matina Campus" into the Route Name text field.
* **Step 3 (Geographic Anchoring):** The user selects the Origin ("Toril Central Terminal") and Destination ("UM Matina Gate") from saved place presets or selects "Pin on Map" to capture exact coordinates.
* **Step 4 (Leg Assembly):** The commuter assembles the consecutive transit legs by tapping '+ Add Transit Step':
  * *Leg 1:* Selects "Tricycle", enters "Neighborhood Gate", enters fare ₱10.00.
  * *Leg 2:* Selects "Modern PUV", enters "Toril Highway Terminal", enters fare ₱23.00.
  * *Leg 3:* Selects "Walking", enters "Matina Crossing to Gate", enters fare ₱0.00.
* **Step 5 (Concession Audit):** The calculation engine automatically aggregates segment tariffs: Base Total = ₱33.00. The active Student Concession applies a 20% statutory discount (₱33.00 × 0.80 = ₱26.40), explicitly displaying cumulative legal savings of ₱6.60.
* **Step 6 (Persistence):** The commuter taps 'Save'. The form validator confirms that the name is non-empty, all boarding landmarks exist, and all fares are non-negative numeric values. The route is committed to local storage.
* **Step 7 (Verification):** The view redirects to the Routes Tab, displaying the newly assembled route card with instant access to 'Reverse Route' and 'Log Trip'.

### Task Journey 2: Quick-Logging a Completed Commute Trip
* **Goal:** Upon boarding public transit, the commuter records their commute expense with a single tap, updating their financial ledger and weekly budget gauge.
* **Step 1 (Trigger):** The commuter launches the app and taps the prominent 'Quick Log Trip' button on the Dashboard card.
* **Step 2 (Contextual Pre-Fill):** The Log Trip modal sheet displays. The commuter selects "Home to UM Matina Campus". The system automatically populates the pre-calculated student fare (₱26.40) and today's timestamp.
* **Step 3 (Verification / Adjustment):** If exact fare was charged, the commuter leaves the amount untouched. If an exceptional traffic detour occurred, the commuter adjusts the value in the numeric text field.
* **Step 4 (Commit):** The commuter taps 'Confirm & Record Trip'. An immutable copy-on-write record is written to the local trips database.
* **Step 5 (Dynamic State Recalculation):** A notification banner confirms "Trip logged successfully". The Dashboard updates immediately: weekly spending increases from ₱89.60 to ₱116.00, and the budget meter shifts to reflect remaining funds.

---

## VIII. Use Case

The use case model delineates functional interactions between the primary actor (the Commuter) and the Pamasahe system. The single actor architecture reflects an offline-first paradigm where all administrative and operational responsibilities remain local to the commuter.

### Use Case Inventory Table

| Use Case ID | Use Case Name | Primary Actor | Module & Trigger | Postcondition |
| :--- | :--- | :--- | :--- | :--- |
| **UC01** | Create Multi-Step Route | Commuter | Routes Tab -> Add Route button | New multi-step route saved in local database. |
| **UC02** | Edit & Update Route Fares | Commuter | Route Details -> Edit button | Route updated; past trips in ledger remain unchanged. |
| **UC03** | Delete Route | Commuter | Route Details -> Delete icon | Route deleted; associated historical trip logs preserved. |
| **UC04** | Calculate Concession Fare | Commuter | Automatic upon route view or edit | Calculates regular vs 20% discounted fare. |
| **UC05** | Reverse Route (Return Trip) | Commuter | Route Card -> Reverse button | Creates cloned route with inverted sequence. |
| **UC06** | Compare Alternative Routes | Commuter | Routes Tab -> Compare Routes button | Side-by-side comparison (Cheapest vs Fastest). |
| **UC07** | Log Completed Trip | Commuter | Home Tab -> Quick Log Trip button | Immutable trip record appended to historical ledger. |
| **UC08** | View Spending Analytics | Commuter | Home Tab -> Analytics / History Tab | 7-day chart & budget progress rendered. |
| **UC09** | Browse Transit Lines & Waypoint Matrix | Commuter | Lines Tab -> Select Line | Calculates exact segment fare from Stop A to Stop B. |
| **UC10** | Pin Place on Draggable Map | Commuter | Settings -> Pin New Place on Map | Saves custom landmark with reverse-geocoded coordinates. |
| **UC11** | Authenticate with Supabase Cloud | Commuter | Settings -> Connect Account / Auth Screen | Session token stored; profile linked with PostgreSQL backend. |
| **UC12** | Cloud Backup & Restore Commute Notebook | Commuter | Settings -> Backup Now / Restore buttons | Local routes, places, and trip ledgers synchronized with cloud database. |
| **UC13** | Discover & Import Community Routes | Commuter | Routes Tab -> Community Routes button | Community transit route duplicated into personal route notebook. |
| **UC14** | Over-The-Air (OTA) Regulated Fare Matrix Sync | Commuter | Lines Tab -> Sync Fares (OTA) button | Local Davao transit line catalog updated with official LTFRB fare matrix. |

### Formal Specification: UC01 — Create Multi-Step Route
* **Primary Actor:** Commuter.
* **Trigger:** The commuter opens the Route Builder form to record a regular transit route.
* **Preconditions:** The application is initialized and local storage is ready.
* **Postconditions:** The new multi-leg route is stored locally and appears in the routes directory.
* **Main Success Flow:**
  1. Commuter taps '+ Add Route'.
  2. System renders the route builder form with route name, From/To place pickers, duration, and empty step list.
  3. Commuter inputs route name and selects origin and destination anchors.
  4. Commuter taps '+ Add Transit Step' and selects transit mode, enters boarding landmark, and inputs segment fare.
  5. Commuter repeats Step 4 for all transit legs.
  6. System computes cumulative base fare and active 20% statutory concession rate.
  7. Commuter taps 'Save'.
  8. System validates inputs, writes record to database, and navigates to route list.
* **Alternative Flows:**
  * *4a. Import from Transit Line:* Commuter taps 'Import from Transit Line': System opens Davao Line catalog, commuter selects route segment, and system auto-populates step parameters.
* **Exception Flows:**
  * *8a. Validation Failure:* If route name is empty, steps list is empty, or any fare is negative/non-numeric, the system highlights offending fields with error text and aborts save.

### Formal Specification: UC07 — Log Completed Trip
* **Primary Actor:** Commuter.
* **Trigger:** Commuter taps 'Quick Log Trip' on the Dashboard or 'Log this trip' on a route card.
* **Preconditions:** At least one saved route exists.
* **Postconditions:** An immutable trip record is appended to the ledger; weekly spending totals are updated.
* **Main Success Flow:**
  1. Commuter initiates log trip action.
  2. System displays route selector with pre-filled discounted fare and current date.
  3. Commuter verifies or adjusts the fare paid and date.
  4. Commuter taps 'Confirm & Record Trip'.
  5. System writes snapshot copy of amount paid, route name, and timestamp.
  6. System updates weekly budget gauge, refreshes 7-day bar chart, and displays success notification banner.

---

## IX. Conceptual Framework

The conceptual framework of Pamasahe is structured around an **Input-Process-Output (IPO)** model, integrating an offline-first reactive architecture with domain-specific Philippine public transit business logic.

### Input - Process - Output (IPO) Model Architecture

| System Inputs | Processing & Business Logic Engines | System Outputs & Deliverables |
| :--- | :--- | :--- |
| • Commuter Route Parameters (Route Name, From/To anchors, duration)<br>• Step Leg Definitions (RideType, Boarding Landmark, Segment Fare)<br>• Statutory Concession Category (Student RA 11314, Senior RA 9994, PWD RA 10754)<br>• Financial Budget Thresholds (Weekly ₱150, Monthly ₱600)<br>• Draggable Map Coordinates (Lat/Long pointer offsets, Hub presets)<br>• Trip Logging Entries (Route ID, actual amount paid, timestamp) | • Statutory Concession Engine (Calculates 20% discount with centavo precision)<br>• Route Reversal Algorithm (Inverts step array, swaps From/To, appends suffix)<br>• Route Comparison Engine (Evaluates cost vs duration across options)<br>• Immutable Copy-on-Write Ledger (Isolates historical records from route edits)<br>• Expense Aggregation Subsystem (Filters Monday-Sunday weekly sums)<br>• Nearest-Neighbor Geocoding (Euclidean distance matching against Davao landmarks)<br>• Reactive State Propagation (`AppStateScope` `ChangeNotifier` notifications) | • Responsive Mobile Interface (Material 3 inside 390x844 `PhoneFrame`)<br>• Interactive 7-Day Expense Bar Chart (Container-based proportional bars)<br>• Dynamic Budget Utilization Gauge (Color-shifting alert states)<br>• Interactive Waypoint Fare Matrices (Stop A -> Stop B calculation)<br>• Slippy Map OpenStreetMap Canvas (Tile streaming with center teardrop pin)<br>• Exportable Trip History CSV Dataset (System clipboard copy) |

### Structural System Architecture & Component Interaction Flow
1. **Presentation Layer:** Composed of the root `MainScaffold`, the responsive `PhoneFrame` shell, and the 5 persistent tab screens hosted inside an `IndexedStack` (Home, Routes, Lines, History, Settings). Widgets observe state via `AppStateScope.of(context)`.
2. **State Management Layer:** Governed by `AppState` (`ChangeNotifier`) encapsulated within `AppStateScope` (`InheritedNotifier`). Manages reactive mutation dispatching, concession discount state, budget limits, and route manipulation methods with $O(1)$ subscriber notification.
3. **Business Logic & Domain Engine:** Enforces core domain rules: concession discount algorithms, route reversal logic, 7-day spending aggregations, and nearest-neighbor Euclidean landmark resolution.
4. **Data & Local Persistence Layer:** Maintains in-memory reactive collections initialized via `InitialData` and backed by strongly typed data contracts (`SavedRoute`, `RouteStep`, `Trip`, `SavedPlace`, `TransportLine`) ready for SQLite table mapping.

---

## X. Gantt Chart

The development lifecycle of Pamasahe follows a structured 14-week timeline spanning a single academic semester (CCE 106). The project progressed through six comprehensive phases from initial transit domain investigation to deployment verification.

### Project Phase Breakdown & Work Breakdown Structure (WBS)

| Phase & Task ID | Task Description & Milestones | Duration | Start - End | Predecessors |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 1: Concept** | 1.1 Literature review & Philippine concession laws (RA 11314)<br>1.2 Davao City transit field studies & terminal mapping<br>1.3 Requirements specification & scope definition | 3 Weeks | Week 1 - Week 3 | None |
| **Phase 2: UI/UX & Arch** | 2.1 Material 3 design tokens, wireframing & task analysis<br>2.2 Layered architecture setup & responsive `PhoneFrame` shell<br>2.3 Conceptual data modeling (SQLite schema & models) | 2 Weeks | Week 4 - Week 5 | Phase 1 |
| **Phase 3: Core Engine** | 3.1 Multi-step route builder form & validation<br>3.2 20% Concession discount calculation engine<br>3.3 Route reversal & side-by-side comparison features | 3 Weeks | Week 6 - Week 8 | Phase 2 |
| **Phase 4: Expense Ledger** | 4.1 Quick trip logger & copy-on-write immutable records<br>4.2 7-Day spending bar chart & Monday-Sunday filter<br>4.3 Weekly/monthly budget meter with color alert states | 2 Weeks | Week 9 - Week 10 | Phase 3 |
| **Phase 5: Catalog & Map** | 5.1 Davao City transit lines catalog & vehicle filters<br>5.2 Interactive Stop A -> Stop B waypoint fare matrix<br>5.3 Draggable OpenStreetMap slippy canvas & geocoding | 2 Weeks | Week 11 - Week 12 | Phase 4 |
| **Phase 6: Testing & QA** | 6.1 Comprehensive unit test suite (`pamasahe_test.dart`)<br>6.2 Widget UI & navigation tests (`widget_test.dart`)<br>6.3 Commuter pilot testing, bug fixes & final report | 2 Weeks | Week 13 - Week 14 | Phase 5 |

### Timeline Gantt Visualization (14-Week Schedule)

![Figure 2.1: Pamasahe 14-Week Project Development Gantt Chart](../diagrams/chapter_2_gantt_chart.png)

```text
PROJECT PHASES                  | W01 | W02 | W03 | W04 | W05 | W06 | W07 | W08 | W09 | W10 | W11 | W12 | W13 | W14 |
--------------------------------+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+
1. Requirements & Transit Study | [=======] |     |     |     |     |     |     |     |     |     |     |     |     |
2. UI/UX & Architecture Design  |     |     |     | [=====] |     |     |     |     |     |     |     |     |     |     |
3. Route Builder & Concession   |     |     |     |     |     | [===========] |     |     |     |     |     |     |     |
4. Expense Ledger & Analytics   |     |     |     |     |     |     |     |     | [=======] |     |     |     |     |     |
5. Transit Catalog & OSM Map    |     |     |     |     |     |     |     |     |     |     | [=======] |     |     |     |
6. Testing, QA & Final Defense  |     |     |     |     |     |     |     |     |     |     |     |     | [=======] |
--------------------------------+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+
```

---

## XI. Test Case

Verification and quality assurance of Pamasahe were conducted through comprehensive automated unit and widget test suites. The test cases below directly map to the automated verification scripts implemented in `pamasahe_test.dart` and `widget_test.dart`, achieving a **100% pass rate** across business logic, state mutations, concession formulas, and interface interactions.

| TC ID | Test Scenario & Precondition | Execution Steps | Expected Results | Actual Results | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC01** | Initial App State & Sample Data Seeding<br>*(Pre: Fresh launch)* | 1. Instantiate `AppState`.<br>2. Query length of routes, trips, places, and initial weekly total. | Routes = 4, Trips = 4, Places = 4, studentDiscount = true, weeklySpending = ₱89.60. | Routes = 4, Trips = 4, Places = 4, studentDiscount = true, weeklySpending = ₱89.60. | **PASS** |
| **TC02** | Statutory 20% Concession Discount Engine<br>*(Pre: Steps ₱20 + ₱30 = ₱50)* | 1. Instantiate `SavedRoute`.<br>2. Query `regularTotal`.<br>3. Call `getDiscountedTotal(true)`.<br>4. Call `getDiscountedTotal(false)`. | `regularTotal` = ₱50.00;<br>Discounted = ₱40.00 (20% off);<br>Un-discounted = ₱50.00. | `regularTotal` = ₱50.00;<br>Discounted = ₱40.00;<br>Un-discounted = ₱50.00. | **PASS** |
| **TC03** | Concession Category Switching (RA 11314 / 9994 / 10754)<br>*(Pre: AppState active)* | 1. `setDiscountType(senior)`.<br>2. Verify badge.<br>3. `setDiscountType(pwd)`.<br>4. `setDiscountType(none)`. | Badge reflects '20% Senior Citizen discount', '20% PWD discount', and 'Regular fare' with discount flag toggled. | Badge text and discount flags updated deterministically across all settings. | **PASS** |
| **TC04** | Automated Return Route Reversal<br>*(Pre: Route 'Home to School')* | 1. Invoke `reverseRoute(original)`.<br>2. Check name, From/To, step order, and segment fares. | Name = 'Home to School (return)'; From = School; To = Home; steps sequence inverted; fares preserved. | Name, endpoints, and step sequences inverted accurately; child fares match original. | **PASS** |
| **TC05** | Trip Logging & Copy-on-Write Ledger Persistence<br>*(Pre: Initial weekly ₱89.60)* | 1. Call `logTrip(routeId:1, amount:26.40, date:'Nov 6, 2026')`.<br>2. Inspect trips collection and weekly total. | Trips count increases by 1; newest entry appears at index 0; weekly spending = ₱116.00. | Trip added at index 0; `weeklySpending` updated to exactly ₱116.00. | **PASS** |
| **TC06** | Cascade Deletion Isolation<br>*(Pre: Route 1 has logged trips)* | 1. `deleteRoute(1)`.<br>2. Verify route removal.<br>3. Verify trips count. | Route 1 is deleted (returns null); trip count remains unchanged (copy-on-write isolation). | Route removed; historical trips remain intact in ledger. | **PASS** |
| **TC07** | Saved Place Location Pinning<br>*(Pre: AppState initialized)* | 1. `addSavedPlaceItem('Dormitory', lat:7.0780, lng:125.6150)`.<br>2. `updateSavedPlaceItem`.<br>3. `deleteSavedPlace`. | Place created with coordinates; updated with new address; deleted successfully. | Saved places collection reflects addition, update, and deletion with zero state errors. | **PASS** |
| **TC08** | Davao Transit Lines Filtering<br>*(Pre: LinesTab rendered)* | 1. Tap 'Bus' filter chip.<br>2. Tap 'All' filter chip. | 'University Loop' bus is visible; jeepney 'Mabini-Poblacion' is hidden; 'All' restores both. | Filter updates list view instantaneously without frame drops. | **PASS** |
| **TC09** | Waypoint A -> B Segment Fare Matrix<br>*(Pre: LineDetailScreen open)* | 1. Tap Point A 'Mabini Road'.<br>2. Tap Point B 'Public Market'. | System renders 'Estimated Segment Fare' and displays 'Use in a route' button. | Segment fare calculated accurately; 'Use in a route' button enabled. | **PASS** |
| **TC10** | Live Search Filtering on Saved Routes<br>*(Pre: 4 saved routes)* | 1. Enter 'Mall' in TextField.<br>2. Enter 'Airport' (no match).<br>3. Tap 'Clear search'. | 'Mall' filters to 2 routes; 'Airport' displays 'No matching routes'; 'Clear search' restores 4 routes. | Dynamic filtering responds in real time; empty state rendered correctly. | **PASS** |
| **TC11** | Budget Progress Meter Color States<br>*(Pre: Weekly budget ₱150)* | 1. Spending at ₱89.60 (59.7%).<br>2. Log trip of ₱40 -> ₱129.60 (86.4%).<br>3. Log trip of ₱30 -> ₱159.60 (106.4%). | Under 75% renders Brand Teal; 75%-99% renders Caution Amber; >=100% renders Alert Coral. | `LinearProgressIndicator` dynamically shifts colors according to threshold rules. | **PASS** |
| **TC12** | Trip History CSV Export to Clipboard<br>*(Pre: 18 logged trips)* | 1. Tap 'Export CSV' button.<br>2. Inspect snackbar/notification banner. | Notification banner confirms CSV copied to clipboard; formatted header and trip rows generated. | CSV copied to clipboard; banner displayed with confirmation message. | **PASS** |
| **TC13** | Supabase Service Offline-Resilient Initialization<br>*(Pre: Zero network / unconfigured keys)* | 1. Instantiate `SupabaseService`.<br>2. Query `isMockMode`. | Service initializes without crashing or throwing unhandled exceptions; `isMockMode` returns true. | Graceful fallback enabled; app functions 100% offline. | **PASS** |
| **TC14** | Supabase User Authentication (Email & Google OAuth)<br>*(Pre: Mock/live client initialized)* | 1. Call `signInWithEmail`.<br>2. Call `signInWithGoogle`.<br>3. Verify returned session and UUID. | Authentication succeeds; valid user email and unique session ID returned for both providers. | Both authentication methods return successful results and session identities. | **PASS** |
| **TC15** | AppState Cloud User Session & Sign-Out Handling<br>*(Pre: Initial AppState)* | 1. `setCloudUser(email, id)`.<br>2. Inspect `isCloudAuthenticated`.<br>3. `signOutCloud()`. | `isCloudAuthenticated` becomes true; email and ID stored; sign-out resets state to null and false. | Session state mutations execute deterministically with UI notification. | **PASS** |
| **TC16** | Cloud Route Notebook Backup & PostgreSQL Sync<br>*(Pre: Authenticated user session)* | 1. Call `state.backupToSupabase()`.<br>2. Verify backup response message and timestamp. | Backup succeeds; message confirms serialization of routes and trips; `lastCloudSync` updated. | Backup completed successfully; timestamp recorded. | **PASS** |
| **TC17** | Crowdsourced Community Routes Discovery & 1-Tap Import<br>*(Pre: Community routes feed active)* | 1. Call `getCommunityRoutes()`.<br>2. Select route and invoke `publishRouteToCommunity()`. | Community repository returns curated Davao routes; published route is appended with unique ID. | Community feed populated; new route published with student author tag. | **PASS** |
| **TC18** | Over-The-Air (OTA) Regulated Fare Matrix Updates<br>*(Pre: AppState with transit catalog)* | 1. Invoke `state.checkAndApplyOtaUpdates()`.<br>2. Verify return record and catalog count. | `hasUpdates` = true; catalog updated with latest LTFRB baseline fare and per-km rates. | 2 Davao transit lines updated to latest LTFRB matrix without app restart. | **PASS** |

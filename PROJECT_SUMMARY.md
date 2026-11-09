# pamasahe: Project Summary and Use Cases

Quiel | Mobile Application Development | Flutter

## 1\. Project summary

BiyaheFare is an offline Flutter mobile app for commuters in the Philippines. The commuter saves the routes they already ride, with the ride type, boarding point and fare of every step. The app then calculates the total fare (with the 20% student discount if it applies), records each trip with one tap, and shows weekly and monthly spending.

**Problem.** New commuters do not know what to ride or pay. Routes with several rides (for example jeepney, then tricycle) are hard to remember. Students rarely know their real monthly transport cost.

**Target user.** Daily commuters, mainly students and first-time commuters.

**How it differs from Sakay.ph.** Sakay.ph is a route planner: it tells you how to get from A to B and needs map data and a routing engine. BiyaheFare is a personal commute notebook: it remembers the routes you already know and shows what they cost you over time. In one sentence: Sakay.ph helps you find a route, BiyaheFare helps you remember it and see what it costs you.

**Design principles.**

* Offline first: all data stays on the phone. No account, no server, no internet needed.
* Every fare is typed in and editable by the user. The app never claims its fares are official.
* Small and finishable: one developer, one semester.

## 2\. Scope

**In scope (build these).** Features F1 to F13 in section 4.

**Stretch (only if time is left).** Share a route with a friend, monthly budget limit with a warning, export trip history as CSV, Filipino language option.

**Out of scope (do not build).** Turn-by-turn directions, GPS or live tracking, user accounts and cloud sync, ticket purchasing. They need a backend or paid map data and would turn the project into a Sakay.ph copy.

Note: F9 to F13 are small additions inspired by Sakay.ph. Confirm with your instructor that they fit the approved scope.

## 3\. Actor

**Commuter** is the only actor. The local SQLite database is part of the system, not an actor. There is no admin because nothing runs on a server.

## 4\. Features

|ID|Feature|What it does|Priority|
|-|-|-|-|
|F1|Route builder|Create a route from steps. Each step has a ride type, boarding point and fare.|Must|
|F2|Edit and delete routes|Change any step or fare, or remove a route.|Must|
|F3|Saved routes list|Browse routes with name, From and To, total fare and travel time.|Must|
|F4|Fare calculator|Adds up all steps of a route into a total fare.|Must|
|F5|Student discount toggle|One switch in Settings applies a 20% discount to calculated fares.|Must|
|F6|Log trip|One tap records a trip with route, date and amount paid. Date and amount are editable.|Must|
|F7|Trip history|List of past trips, newest first.|Must|
|F8|Spending summary|Weekly and monthly totals with a chart.|Must|
|F9|Travel time and compare routes|Each route has an optional travel time in minutes. A compare screen shows the cheapest and the fastest.|Should|
|F10|More ride types|Jeepney, Bus, P2P bus, UV Express, MRT/LRT/PNR train, Ferry, Tricycle, E-jeep.|Should|
|F11|Saved places|Labels such as Home and School used as From and To on routes.|Should|
|F12|Reverse route|One tap creates the return route (steps in reverse order, From and To swapped).|Should|
|F13|Fare last updated|Each route remembers the date its fares were last edited. The app warns when they are old.|Should|

## 5\. Screens

1. **Home:** this week's spending, a Log trip button and shortcuts to Routes and History.
2. **Routes list:** all saved routes (F3), with an Add route button.
3. **Add or edit route:** form with name, From, To, travel minutes and a list of steps (F1, F2, F10, F11).
4. **Route detail:** the steps, total fare, discounted total, last-updated date, Reverse route and Log this trip buttons (F4, F12, F13).
5. **Compare routes:** side-by-side cost and time (F9).
6. **Log trip:** choose a route, confirm amount and date (F6).
7. **Trip history:** list of trips (F7).
8. **Spending summary:** week or month toggle, total and chart (F8).
9. **Settings:** student discount switch and saved places (F5, F11).

## 6\. Data model (SQLite)

SQLite is a small database stored inside the app. It needs the `sqflite` package in Flutter. A foreign key is a column that points to a row in another table. `ON DELETE CASCADE` automatically deletes the child rows (the steps) when the parent row (the route) is deleted.

```sql
CREATE TABLE places (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
);

CREATE TABLE routes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  from\_place\_id INTEGER,
  to\_place\_id INTEGER,
  travel\_minutes INTEGER,
  fares\_updated\_at TEXT NOT NULL,
  FOREIGN KEY (from\_place\_id) REFERENCES places(id),
  FOREIGN KEY (to\_place\_id) REFERENCES places(id)
);

CREATE TABLE route\_steps (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route\_id INTEGER NOT NULL,
  step\_order INTEGER NOT NULL,
  ride\_type TEXT NOT NULL,
  boarding\_point TEXT NOT NULL,
  fare REAL NOT NULL,
  FOREIGN KEY (route\_id) REFERENCES routes(id) ON DELETE CASCADE
);

CREATE TABLE trips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  route\_id INTEGER,
  route\_name TEXT NOT NULL,
  trip\_date TEXT NOT NULL,
  amount\_paid REAL NOT NULL,
  FOREIGN KEY (route\_id) REFERENCES routes(id) ON DELETE SET NULL
);

CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

**Design decisions to remember.**

* `trips` stores `amount\_paid` and `route\_name` as a copy. Editing or deleting a route later must not change or erase past trips.
* Dates are stored as text in `YYYY-MM-DD` format, which sorts correctly.
* SQLite ignores foreign keys unless you run `PRAGMA foreign\_keys = ON` when opening the database.
* The student discount is stored in `settings` (key `student\_discount`, value `1` or `0`). A quick hack is `shared\_preferences`, but one storage place is simpler.
* Spending summary: `SELECT SUM(amount\_paid) FROM trips WHERE trip\_date BETWEEN ? AND ?`. Weeks start on Monday.

## 7\. Tech stack

|Package|Used for|
|-|-|
|Flutter and Dart|The app|
|`sqflite` and `path`|Local SQLite database|
|`provider`|State management (sharing data between screens). Proper industry options are Riverpod or Bloc, but Provider is easiest to learn.|
|`fl\_chart`|Spending chart|
|`intl`|Peso and date formatting|
|`share\_plus`|Stretch: share a route|
|`flutter\_test`|Unit tests for the fare calculation|

**Fare calculation.** Total = sum of all step fares. If the student discount is on, discounted total = total × 0.80, rounded to 2 decimals. Real operators may round discounted fares differently, so show the result as an estimate.

## 8\. Use case list

See the use case diagram. The actor is the Commuter. Apply student discount is an optional extension of Calculate fare.

|ID|Use case|Feature|
|-|-|-|
|UC1|Add route|F1, F10, F11, F13|
|UC2|Edit route and fares|F2, F13|
|UC3|Delete route|F2|
|UC4|View saved routes|F3|
|UC5|Calculate fare (extended by Apply student discount)|F4, F5, F13|
|UC6|Log trip|F6|
|UC7|View trip history|F7|
|UC8|View spending summary|F8|
|UC9|Compare routes|F9|
|UC10|Reverse route|F12|

## 9\. Written use cases (required three)

### UC1: Add route

* **Actor and trigger:** Commuter taps Add route, fills in the form and taps Save.
* **Precondition:** The app is open and the local database is ready.
* **System responses:**

  1. Displays the route form: route name, From and To (chosen from saved places), optional travel minutes, and a list of steps (ride type, boarding point, fare).
  2. Accepts the commuter's input for each step.
  3. Validates the input.
  4. Saves the route and its steps to the local database and sets the fares-updated date to today.
  5. Shows the new route in the route list with its total fare and travel time.
* **Validation:** Route name is not empty. There is at least one step. Every boarding point is not empty. Every fare is a number greater than 0. Travel minutes, if entered, is a whole number greater than 0.
* **Error response:** If any check fails, the system does not save, highlights the field and shows a message such as “Enter a fare greater than 0”.
* **Postcondition:** The route and its steps are stored and appear in the route list.

### UC5: Calculate fare

* **Actor and trigger:** Commuter selects a saved route and taps Calculate fare.
* **Precondition:** At least one saved route exists and it has at least one step.
* **System responses:**

  1. Loads the selected route's steps from the database.
  2. Adds up the fare of every step.
  3. If the student discount is on (Apply student discount extension), reduces the total by 20%.
  4. Displays the total fare, with the discount shown separately.
  5. Shows the date the fares were last updated, with a note “Fares may be outdated” when that date is more than 90 days old.
* **Validation:** The system checks that the route exists and that every step has a valid fare before calculating.
* **Error response:** If a fare is missing or invalid, the system shows “Fare missing for step 2. Edit the route to fix it” and displays no total.
* **Postcondition:** The total is shown on screen. No stored data changes.

### UC6: Log trip

* **Actor and trigger:** Commuter taps Log trip, chooses a route and taps Save.
* **Precondition:** At least one saved route exists.
* **System responses:**

  1. Displays the saved routes for selection.
  2. Shows the fare (discounted if the discount is on) and today's date, both editable.
  3. Validates the route, amount and date.
  4. Records the trip (route, route name, date, amount paid) in the database.
  5. Updates the weekly and monthly totals and shows a confirmation.
* **Validation:** A route is selected. The amount is a number greater than 0. The date is not in the future.
* **Error response:** If a check fails, the system shows “Choose a route and enter an amount greater than 0”, keeps the form open and saves nothing.
* **Postcondition:** The trip is stored in the trip history, and the weekly and monthly totals include it.

## 10\. Other use cases (short form)

|ID|Use case|Trigger and system response|Validation and error|Postcondition|
|-|-|-|-|-|
|UC2|Edit route and fares|Commuter taps Edit on a route. The system loads it into the form, applies the same checks as UC1 and saves. If any fare changed, it sets the fares-updated date to today.|Same checks and messages as UC1.|Route updated. Past trips are unchanged.|
|UC3|Delete route|Commuter taps Delete. The system asks for confirmation, then deletes the route and its steps.|If the commuter cancels, nothing changes. If the database fails: “Could not delete. Try again.”|Route removed. Trips stay in history.|
|UC4|View saved routes|Commuter opens Routes. The system lists each route with name, From and To, total fare and minutes.|If there are none, it shows “No routes yet. Add your first route.”|Nothing changes.|
|UC7|View trip history|Commuter opens History. The system lists trips newest first with date, route name and amount.|If there are none, it shows “No trips logged yet.”|Nothing changes.|
|UC8|View spending summary|Commuter picks Week or Month. The system sums the trips in that period and draws the chart.|If there are no trips, it shows “No trips in this period.”|Nothing changes.|
|UC9|Compare routes|Commuter selects routes and taps Compare. The system shows cost and time side by side and marks the cheapest and the fastest.|With fewer than two routes: “Save at least two routes to compare.” A route without minutes shows “No time set”.|Nothing changes.|
|UC10|Reverse route|Commuter taps Reverse route. The system creates a copy named “(return)” with steps in reverse order and From and To swapped, then opens it for editing.|If saving fails: “Could not create the return route.”|A new route is saved. The original is unchanged.|

## 11\. Suggested build order

1. **Setup:** Create the Flutter project, add packages, write the database helper (tables from section 6) and check it works.
2. **Routes:** Add route, Edit, Delete and the Routes list (UC1 to UC4) with all validations.
3. **Fare calculator:** Route detail screen, total fare, discount switch and unit tests (UC5).
4. **Trips:** Log trip and Trip history (UC6, UC7).
5. **Summary:** Spending summary with chart (UC8).
6. **Extras:** Saved places, more ride types, travel time with Compare, Reverse route, fare last-updated note (UC9, UC10).
7. **Polish and test:** Empty states, error messages, airplane-mode test, and a trial with two or three real commuters.

Keep every step working before moving on. If time runs short, stop after step 5: that is a complete app.

## 12\. Test checklist

* Steps of 13 and 20 pesos give a total of 33. With the discount on, the total is 26.40.
* Discount switch off and on changes the total correctly.
* Validation: empty route name, fare of 0, text in a fare field, no steps.
* Deleting a route keeps its trips in history.
* Editing a fare does not change the amount of past trips.
* Reverse route lists the steps in the opposite order and swaps From and To.
* Weekly total counts only Monday to Sunday of the current week.
* The whole app works in airplane mode.

## 13\. Assumptions and notes

* All fares and routes are entered by the user and are not official.
* The 20% student discount follows the Student Fare Discount Act (RA 11314). Real operators may round the discounted fare differently.
* The 90-day “fares may be outdated” limit is a design choice and can be changed.
* F9 to F13 are small additions inspired by Sakay.ph and should be confirmed against the approved project scope.


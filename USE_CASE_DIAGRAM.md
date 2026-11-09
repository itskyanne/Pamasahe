# Pamasahe — Use Case Diagram & Specification

## 1. How to Generate Your Diagram Image

### Option A: Using Mermaid Live Editor (Fastest — 10 seconds)
1. Go to **[mermaid.live](https://mermaid.live/)** in your browser.
2. In the left panel ("Code"), paste the **Mermaid Diagram Code** from Section 2 below.
3. The visual use case diagram will instantly render on the right.
4. Click **Actions** > **Download PNG** or **Download SVG** to save the image for your documentation or slides.

### Option B: Using Draw.io (app.diagrams.net)
1. Go to **[app.diagrams.net](https://app.diagrams.net/)**.
2. Click **Arrange** (in the top menu) > **Insert** > **Advanced** > **Mermaid**.
3. Paste the code below and click **Insert**.
4. You can now edit shapes, move nodes around, and style them to match your instructor's sample.

---

## 2. Mermaid Diagram Code (Copy & Paste)

```mermaid
flowchart LR
    Commuter((Commuter))

    AppNode["Pamasahe Commuter\nModule"]

    Commuter --> AppNode

    %% Module 1: Dashboard
    HomeMod["Commute Dashboard\nModule"]
    AppNode -. "<include>" .-> HomeMod
    HomeMod -. "<include>" .-> UC_Weekly["View Weekly Total\n& Bar Chart"]
    HomeMod -. "<include>" .-> UC_Recent["View Recent Trips"]
    HomeMod -. "<extend>" .-> UC_QuickLog["Quick Log Trip"]

    %% Module 2: Routes
    RouteMod["Route Notebook\nModule"]
    AppNode -. "<include>" .-> RouteMod
    RouteMod -. "<include>" .-> UC_BrowseR["Browse Saved Routes"]
    RouteMod -. "<include>" .-> UC_AddR["Create Multi-Step Route"]
    RouteMod -. "<extend>" .-> UC_ReverseR["Reverse Route\n(Return Trip)"]
    RouteMod -. "<extend>" .-> UC_CompareR["Compare Routes\n(Cheapest / Fastest)"]

    %% Module 3: Transport Lines
    LineMod["Transport Lines\nReference Module"]
    AppNode -. "<include>" .-> LineMod
    LineMod -. "<include>" .-> UC_BrowseL["Browse Public Transit Lines"]
    LineMod -. "<extend>" .-> UC_FilterL["Filter by Vehicle Type\n& Search Name"]
    LineMod -. "<extend>" .-> UC_Waypoints["Interactive Waypoint A/B\nFare Calculation"]
    LineMod -. "<extend>" .-> UC_UseLine["Use Line in Custom Route"]

    %% Module 4: History & Logging
    HistoryMod["Trip Logging &\nHistory Module"]
    AppNode -. "<include>" .-> HistoryMod
    HistoryMod -. "<include>" .-> UC_LogTrip["Log Completed Trip"]
    HistoryMod -. "<include>" .-> UC_TripHistory["View Trip History List"]
    HistoryMod -. "<extend>" .-> UC_Analytics["View Spending Summary\n& Concession Savings"]

    %% Module 5: Settings & Customization
    SettingsMod["Settings & Places\nModule"]
    AppNode -. "<include>" .-> SettingsMod
    SettingsMod -. "<include>" .-> UC_Discount["Configure Concession\n(Student / Senior / PWD)"]
    SettingsMod -. "<extend>" .-> UC_MapPicker["Pin Desired Location\non Draggable Map"]
```

---

## 3. Module & Feature Summary Table (For Report / Defense)

| Module | Core Features (`<<include>>`) | Optional / Extended Features (`<<extend>>`) |
| :--- | :--- | :--- |
| **1. Commute Dashboard (Home)** | • View Weekly Spending Total<br>• View 7-Day Expense Bar Chart<br>• View Recent Commute Trips | • Quick "Log Trip" Action<br>• Open Detailed Spending Analytics |
| **2. Route Notebook** | • Browse Saved Commute Routes<br>• Create Multi-Step Commute Route<br>• View Detailed Route Timeline | • Auto-Fill Step from Catalog Line<br>• Reverse Route (Return Trip)<br>• Compare Routes (Cheapest & Fastest) |
| **3. Transport Line Catalog** | • Browse Public Transport Lines<br>• View Stops Timeline & Details<br>• Calculate Segment Waypoint Fares | • Filter by Vehicle Type & Search<br>• Interactive A/B Waypoint Selection<br>• Export Line to Custom Route<br>• Add / Edit / Delete Custom Lines |
| **4. Trip Logging & History** | • Log Completed Commute Trip<br>• View Chronological Trip History | • View Weekly/Monthly Spending Analytics<br>• View Concession Savings Insight |
| **5. Settings & Customization** | • Toggle Concession Discount (20%)<br>• Select Category (Student/Senior/PWD)<br>• Manage Saved Places List | • Pin Place on Draggable Map (Shopee/Foodpanda style)<br>• Quick Transit Hub Presets<br>• Live Coordinate & Address Lookup |

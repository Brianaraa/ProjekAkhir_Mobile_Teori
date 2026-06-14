# Hagati - Hajatan & Adat Digital 🕊️✨

**Hagati** is a production-ready Flutter mobile application designed to simplify the planning, execution, and management of traditional Indonesian events and weddings. By blending rich cultural heritage with modern technology, Hagati bridges traditional customs (*adat*) and seamless digital coordination.

This project is built using modern mobile architecture patterns, offline-first data persistence, hardware sensor integration, and secure authentication, representing a complete, real-world application structure.

---

## 🌟 Features & Technical Highlights

### 1. Hardware Sensor Integration & Gamification
* **3D Accelerometer Simulation**: Features an interactive "Balance Game" simulating the balancing of traditional ceremonial trays (*Adat* offerings).
* **Gravity Compensation**: Integrates real-time accelerometer data ($x$, $y$, $z$ axes) combined with gravitational compensation ($9.8\text{ m/s}^2$) to calculate tilting thresholds dynamically:
  $$\text{Acceleration Magnitude} = \sqrt{x^2 + y^2 + z^2}$$
* **Adaptive Difficulty Curve**: Adjusts tilt tolerance dynamically using progression formulas scaled by player levels.

### 2. Offline-First Repository Pattern (Local Cache Sync)
* **Dual Database Architecture**: Combines **Supabase (PostgreSQL)** for cloud synchronization with **SQLite (via `sqflite`)** for local caching.
* **Network-Aware Repository**: Uses `connectivity_plus` to monitor internet states. Bookmarked vendors and events are readable and manageable offline, automatically synchronizing back to the cloud database once connection restores.

### 3. Biometric & Secure Authentication
* **Hardware Security**: Integrates `local_auth` to authenticate users using native iOS FaceID / Android Fingerprint sensors.
* **Secured Encryption**: Encrypts and matches user data using SHA-256 with dynamic salting mechanisms, preventing database credentials compromise.

---

## 📱 App Features

### 👤 Customer App
* **Interactive Vendor Map**: Integrates `flutter_map` with OpenStreetMap tile rendering to locate traditional makeup, decoration, and catering services within geographic coordinates.
* **Budget Estimator**: Provides dynamic budgeting calculations adjusted to the scale of the wedding and selected regional adat customs.
* **Interactive Seating Arranger**: Interactive canvas for guests' seating layouts.
* **Conversion Tools**: Built-in Currency and Timezone converter for international families and invitees.
* **Smart Reminders**: Utilizes `flutter_local_notifications` to push reminders and custom alerts on D-day.

### 🔑 Admin Panel (Integrated Access Control)
* **Real-time Dashboard**: Overview statistics of active bookings, total revenues, and registered vendors.
* **Vendor & Service Management**: CRUD control for admins to list, edit, verify, or toggle vendor statuses.
* **Security & Log Tracking**: Automated log tracing to record admin actions (`admin_log` table), ensuring database integrity and action audit trails.

---

## 🛠️ Technology Stack & Dependencies

* **Frontend Framework**: Flutter (Dart)
* **Backend Database**: Supabase (PostgreSQL, Realtime subscriptions)
* **Local Caching**: SQLite (`sqflite`), `shared_preferences`
* **Geospatial Mapping**: `flutter_map`, `latlong2`
* **Device Hardware API**: `sensors_plus` (Accelerometer), `local_auth` (Biometrics), `permission_handler`
* **Local Utility**: `flutter_local_notifications`, `timezone`, `crypto` (SHA-256 hashing)

---

## 📂 Architecture & Directory Structure

This project follows a clean, modular structure separating features, logic, models, and data access layers:

```
lib/
├── admin/          # Admin pages (Dashboard, Booking, Vendor Management)
├── auth/           # Authentication logic (Biometrics, User/Admin Auth Services, Auth Gates)
├── models/         # Data Models (User, Admin, Vendor, Layanan, Bookings)
├── pages/          # Customer pages (Home, Explorer, Maps, Games, Estimator)
├── services/       # Network Services & Repository Implementations (Supabase, SQLite)
├── widgets/        # Reusable UI Components
└── main.dart       # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.11.0 or higher recommended)
* Supabase Account (For Cloud PostgreSQL Database)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ProjekAkhir_Mobile_Teori.git
   cd ProjekAkhir_Mobile_Teori
   ```

2. **Configure Environment Variables**
   Create a `.env` file in the root folder of the project:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-public-key
   ```

3. **Get dependencies**
   ```bash
   flutter pub get
   ```

4. **Prepare the Supabase Database**
   Run the SQL schema script located in the database setup guide inside your Supabase SQL Editor. This will create:
   * Tables: `users`, `admin`, `vendor`, `layanan`, `bookings`, `bookmark`, `countdown`, `review`, `kesan_pesan`, and `admin_log`.

5. **Run the application**
   ```bash
   flutter run
   ```

---

## ✉️ Developer Profile

Designed & Developed by:
Aulia Putri Naharani & Brian Zahran Putra

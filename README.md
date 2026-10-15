# 🏛️ Smart TV Visitor Welcome & Real-Time Sync System (webOS 22)

> **Enterprise Multi-Screen Guest Welcome, Gate QR Check-In, and Automated Slideshow Architecture**  
> Designed for **3x LG Smart TVs running webOS 22** with Centralized Admin & Instant Mobile Gate Check-In.

---

## 📑 Project Documentation Index

Aapke project ke sabhi technical, architectural, setup aur deployment aspects ko detail me cover karne ke liye separate dedicated manuals create kiye gaye hain:

| Document | Topic & Focus Area | Description |
| :--- | :--- | :--- |
| [01_INTRODUCTION_AND_OVERVIEW.md](file:///e:/project/visitor/docs/01_INTRODUCTION_AND_OVERVIEW.md) | **Introduction & Architecture** | Project vision, problem statement, core 4 components, and end-to-end data flow. |
| [02_TECH_STACK_AND_DECISIONS.md](file:///e:/project/visitor/docs/02_TECH_STACK_AND_DECISIONS.md) | **Tech Stack & Architectural Decisions** | Kyun humne Node.js, WebSockets, Flutter MVVM aur webOS HTML5 choose kiya (In-depth justification). |
| [03_LOCAL_SETUP_AND_SIMULATOR_GUIDE.md](file:///e:/project/visitor/docs/03_LOCAL_SETUP_AND_SIMULATOR_GUIDE.md) | **Localhost & Simulator Setup** | Windows machine par backend run karna, webOS TV 22 Simulator me app launch karna, aur live testing. |
| [04_PRODUCTION_DEPLOYMENT_AND_TV_INSTALLATION.md](file:///e:/project/visitor/docs/04_PRODUCTION_DEPLOYMENT_AND_TV_INSTALLATION.md) | **Production Hosting & TV Deployment** | Real project hosting (Cloud/Local Mini PC), SSL HTTPS setup, webOS IPK packaging, and physical TV deployment. |
| [05_USER_ROLES_PERMISSIONS_AND_SECURITY.md](file:///e:/project/visitor/docs/05_USER_ROLES_PERMISSIONS_AND_SECURITY.md) | **Roles, Permissions & Security** | Visitor, Admin, aur TV Displays ke rights, moderation privacy, aur security best practices. |
| [06_API_AND_WEBSOCKET_SPECIFICATION.md](file:///e:/project/visitor/docs/06_API_AND_WEBSOCKET_SPECIFICATION.md) | **API & WebSocket Specifications** | Sabhi REST endpoints, WebSocket event payloads, aur database structure ki complete reference. |

---

## ⚡ Quick Start (Local Run in 60 Seconds)

1. **Start the Central Sync Server:**
   ```bash
   cd e:\project\visitor\server
   npm install
   npm start
   ```
2. **Access Portals:**
   - 📱 **Gate Visitor Check-In:** `http://localhost:5000/gate`
   - 🎛️ **Admin Control Dashboard:** `http://localhost:5000/admin`
   - 📺 **webOS 22 TV Display:** `http://localhost:5000/tv?tvId=tv1`
3. **Launch in webOS 22 Simulator:**
   - Open `webOS_TV_22_Simulator.exe`
   - Click `File -> Launch App` (`Ctrl + A`)
   - Select folder: `E:\project\visitor\tv_display_webos`
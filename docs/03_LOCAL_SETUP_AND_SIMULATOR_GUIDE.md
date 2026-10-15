# 💻 03. Local Setup & webOS Simulator Guide

---

## 1. Prerequisites (Pehle Kya Hona Chahiye)

1. **Operating System:** Windows 10 / 11 (64-bit)
2. **Node.js:** Version 18+ ya 20+ installed (`node -v` check karein)
3. **webOS TV 22 Simulator:** Jo aapne download kiya hai (`webOS_TV_22_Simulator_1.4.1_win.zip`)
4. **Web Browser:** Google Chrome, Edge, ya Firefox

---

## 2. Step-by-Step Server Setup (Local Machine)

### Step 1: Server Directory Me Jayein
Terminal ya Command Prompt kholein:
```powershell
cd E:\project\visitor\server
```

### Step 2: Dependencies Install Karein
```powershell
npm install
```
*(Dependencies: express, socket.io, multer, cors)*

### Step 3: Server Start Karein
```powershell
npm start
```
Terminal par output aayega:
```
====================================================
🚀 Smart TV Visitor Sync Hub is LIVE on Port 5000
📱 Visitor Gate Check-in: http://localhost:5000/gate
🎛️ Admin Dashboard:        http://localhost:5000/admin
📺 webOS 22 TV Display:    http://localhost:5000/tv
====================================================
```
Server ab background me live hai!

---

## 3. webOS TV 22 Simulator Me App Kaise Launch Karein

Aapke pass jo `webOS_TV_22_Simulator.exe` hai, usme app setup karna bohot aasan hai:

1. **Simulator Open Karein:**
   - `webOS_TV_22_Simulator.exe` par double click karke run karein.
   - Aapke samne virtual LG TV window open hogi with screensaver aur right side me LG Magic Remote.

2. **App Launch Option Select Karein:**
   - Top-left menu me **`File`** par click karein.
   - **`Launch App`** select karein (ya keyboard shortcut **`Ctrl + A`** dabayein).

3. **Folder Select Karein:**
   - Ek folder picker window khulegi.
   - Is folder path par browse karein:
     ```text
     E:\project\visitor\tv_display_webos
     ```
   - **Select Folder** par click karein.

4. **App Automatically Boot Ho Jayegi:**
   - Simulator me humara **Smart TV Welcome Display** full screen me start ho jayega!
   - Top-left par badge aayega: `PATEL RESIDENCE • Living Room TV (TV 1) • ONLINE`.
   - Photos ambient smooth zoom/pan ke sath rotate hona shuru ho jayengi.

---

## 4. Multi-Device Simulation (Teeno TVs Ek Saath Test Karna)

Aap ek hi computer par poore ghar ke teeno TVs aur gate portal ko ek sath test kar sakte hain:

| Window / Screen | URL / Command | Role in System |
| :--- | :--- | :--- |
| **Simulator Screen** | `tv_display_webos` via `File -> Launch App` | **TV 1 (Living Room Primary Display)** |
| **Browser Window 2** | `http://localhost:5000/tv?tvId=tv2` | **TV 2 (Dining Hall Display)** |
| **Browser Window 3** | `http://localhost:5000/tv?tvId=tv3` | **TV 3 (Upper Lounge Display)** |
| **Browser Window 4** | `http://localhost:5000/admin` | **Client Admin Dashboard (Controller)** |
| **Browser Window 5 / Phone** | `http://localhost:5000/gate` | **Gate QR Visitor Portal** |

---

## 5. End-to-End Live Testing Walkthrough

1. Sabhi windows open karne ke baad Admin Dashboard (`http://localhost:5000/admin`) dekhein.
   - Teeno TVs ke aage green **"ONLINE"** badge dikhai dega.
2. Ab Gate Portal (`http://localhost:5000/gate`) par jayein:
   - Name likhein: `Ramesh Shah & Family`
   - Phone: `+91 98765 43210`
   - Ek group photo select karein.
   - **"Check In & Broadcast to TVs"** button dabayein.
3. **Magic Dekhein:**
   - Submit hote hi microsecond me teeno TVs par soft harmonic welcome chime baje ga.
   - Ambient slideshow turant hat jayega aur **Luxury Welcome Card** aayega: *"A Warm Welcome To Ramesh Shah & Family"*.
   - Visitor ki upload ki hui group photo full screen me dikhegi.
   - **5-Minute Countdown Bar (05:00)** chalna shuru ho jayega.
4. **5 Minute Ke Baad:**
   - 300 second poore hote hi TV bina kisi lag ke wapas ambient mode me shift ho jayegi aur database ki sabhi photos ko randomly slideshow karne lagegi!

---

## 6. Running the Flutter MVVM Admin App (Optional / Mobile App Testing)

Agar aap client ke liye native Flutter application run karna chahte hain:

```powershell
cd E:\project\visitor\flutter_admin_portal
flutter pub get
flutter run -d chrome
# ya Windows desktop application ke liye:
flutter run -d windows
```
Flutter app open ho jayegi jo backend port 5000 se directly connect hokar real-time status dikhayegi.

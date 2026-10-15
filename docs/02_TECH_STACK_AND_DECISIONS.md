# ⚙️ 02. Technology Stack & Architectural Decisions

---

## 1. Overview of Technology Stack

| Layer | Selected Technology | Alternative Considered | Primary Decision Driver |
| :--- | :--- | :--- | :--- |
| **TV Display Engine** | **HTML5 + CSS3 (GPU Accelerated) + Web Audio API** | React Native / Flutter Web for TV | Low memory footprint (<60MB RAM) on webOS TV hardware, native 60fps animations. |
| **Realtime Backend** | **Node.js + Express + Socket.io** | Python Flask / Django / Firebase | Sub-50ms bi-directional WebSocket broadcast across multiple screens with zero setup overhead. |
| **Admin Controller** | **Flutter (MVVM) & Web Dashboard** | Plain HTML / React only | Enterprise-grade structure, cross-platform Android/iOS/Web support with strict testability. |
| **Database & Storage** | **Local Persistent JSON Engine + Multipart CDN** | PostgreSQL / MongoDB | Zero-configuration setup; works 100% offline on a private residence local LAN server. |
| **Visitor Gate Portal** | **Lightweight Mobile Web + Canvas Compression** | Native Mobile App | Zero friction (no app download/install), instant load under 1.2s on mobile 4G/5G. |

---

## 2. In-Depth Technical Decision Rationale

### A. Kyun webOS HTML5 Native TV App Choose Kiya?
* **Hardware Reality of Smart TVs:**
  - LG Smart TVs (webOS 22) me 4K panel aur strong video decoding processor hota hai, lekin **CPU processing power aur RAM limited hoti hai** (approx 1.5GB RAM poore OS aur apps ke liye).
  - Agar hum TV par heavy frameworks (jaise heavy React bundles ya heavy runtime layers) daalenge, toh TV kuch ghante chalne ke baad lag karne lagegi ya RAM out-of-memory crash ho jayega.
* **Humara Solution (Zero-Leak GPU Animation):**
  - Humne TV app ko lightweight **HTML5 + CSS 3D Transforms** (`translate3d`, `scale3d`) me design kiya hai. Isse animations CPU par nahi, TV ke GPU par run hoti hain.
  - Memory consumption 60MB se kam rehti hai, jisse TVs **24 ghante, 365 din bina lag ya freeze huye** continuous slideshow chala sakti hain.
* **Synthesized Web Audio API Chime:**
  - MP3 audio files load karne ki jagah humne Web Audio API ke 4 harmonic frequencies (C5, E5, G5, C6) se live soft musical chime synthesize kiya hai. Isse external audio files ke 404 ya codec failure ka 0% chance rehta hai.

### B. Kyun Node.js + Socket.io Real-Time Engine?
* **Sub-50ms Multi-Screen Synchronization:**
  - Normal HTTP polling (jisme TV har 3 second me server ko poochti hai "kya naya visitor aaya?") network bandwidth waste karta hai aur 3 TVs ke beech 2-3 second ka time mismatch paida karta hai.
  - Socket.io persistent WebSocket connection maintain karta hai. Jaise hi gate par visitor "Submit" dabata hai, server microsecond me `io.emit('TRIGGER_WELCOME_SHOW')` fire karta hai aur **teeno TVs 50ms ke andar ek saath welcome screen par switch hoti hain**.

### C. Kyun Client-Side Image Compression at Gate?
* **The Problem:**
  - Modern smartphones (iPhone, Samsung, OnePlus) 12MP se 50MP ke photos click karte hain jinka file size **10MB se 25MB** hota hai.
  - Visitor gate par khada hota hai jahan mobile tower signal weak ho sakta hai. 25MB upload hone me 15-20 second lag sakte hain.
* **The Architecture:**
  - Visitor ke browser me humne HTML5 `<canvas>` dynamic compressor inject kiya hai.
  - Phone par photo select hote hi browser usse 180ms ke andar max 1600px width me resize karke high-quality JPEG me compress karta hai.
  - File size **15MB se ghat kar 600KB - 800KB** ho jata hai. Upload 1 second ke andar complete ho jata hai bina image quality degrade kiye.

### D. Kyun Enterprise Flutter MVVM for Admin?
* **Separation of Concerns:**
  - **Model:** Data integrity aur JSON parsing (`VisitorModel`, `TVDeviceModel`).
  - **Repository:** Network calls aur error handling (`VisitorRepository`, `TVSyncRepository`).
  - **ViewModel:** State management (`AdminViewModel`) with explicit states: `Loading`, `Success`, `Error`, `Empty`.
  - **View:** UI rendering only (`AdminDashboardView`), pure state observation without business logic.
* **Centralized Configuration:**
  - Kisi bhi color, endpoint, ya string ko hardcode nahi kiya gaya hai (`AppColors`, `AppConsts`, `AppString`). Future me agar client ko koi title ya theme badalna ho toh 1 line me change ho sakta hai.
* **Cross-Platform Readiness:**
  - Same codebase se client ke Android phone ki APK, iPhone ke liye iOS app, aur laptop ke liye Web dashboard build hota hai.

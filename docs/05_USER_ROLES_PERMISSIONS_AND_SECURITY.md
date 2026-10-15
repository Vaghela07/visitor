# 🛡️ 05. Roles, Permissions & Security Architecture

---

## 1. User Roles & Permission Matrix

System me **3 Primary Actors** hain jinke rights aur boundaries clearly defined hain:

| Feature / Action | 📱 Visitor (Guest at Gate) | 🎛️ Host / Admin (Homeowner) | 📺 Smart TV (webOS Display) |
| :--- | :---: | :---: | :---: |
| **Scan Gate QR Code** | ✅ Yes | ✅ Yes | ❌ No |
| **Submit Name & Group Photo** | ✅ Yes | ✅ Yes | ❌ No |
| **View Other Visitors' Data / Numbers** | ❌ No | ✅ Yes | ❌ No |
| **Moderate / Approve / Reject Photos** | ❌ No | ✅ Yes | ❌ No |
| **Toggle Auto-Approve Mode** | ❌ No | ✅ Yes | ❌ No |
| **Send Instant Broadcast Alert to TVs** | ❌ No | ✅ Yes | ❌ No |
| **Monitor 3-TV Online Status** | ❌ No | ✅ Yes | ❌ No |
| **Delete Photos from Slideshow** | ❌ No | ✅ Yes | ❌ No |
| **Render Slideshow & Priority Takeover** | ❌ No | ❌ No | ✅ Yes |
| **Send Periodic Heartbeat Ping** | ❌ No | ❌ No | ✅ Yes |

---

## 2. Detailed Role Definitions

### 1. Visitor / Guest (Gate QR User)
* **Context:** Jab visitor client ke ghar ke gate par pahunchta hai.
* **Capabilities:**
  - Phone ke camera se gate par laga QR code scan karna.
  - Apna ya family ka naam likhna.
  - Mobile number enter karna (optional).
  - Front camera ya back camera se host ke sath group photo capture/upload karna.
  - Client-side compression dwara instant upload speed prapt karna.
* **Security Restriction:**
  - Visitor ko kisi bhi dusre guest ka record, phone number, ya photo gallery dikhai nahi deti.
  - Visitor TV settings ya slideshow control nahi kar sakta.

### 2. Host / Admin (Homeowner / Client)
* **Context:** Client apne smartphone ya laptop se system manage karta hai.
* **Capabilities:**
  - **Live TV Monitoring:** Dekh sakta hai ki Living Room, Dining Hall aur Lounge TV online hain ya offline.
  - **Moderation Mode Switch:**
    - *Auto-Approve ON:* Gate par photo upload hote hi direct TVs par display ho jati hai.
    - *Auto-Approve OFF:* Photo pehle admin panel par review ke liye aati hai; client "Approve" dabata hai tabhi TVs par dikhti hai.
  - **Force Welcome Re-run:** Kisi purane visitor ka welcome screen dubara 5 minute ke liye TVs par chalana.
  - **Instant Home Broadcast:** Message type karke teeno TVs par turant banner alert dikhana (e.g. *"Dinner is served"*).
  - **Photo Library Management:** Kisi bhi inappropriate ya purani photo ko 1 click me permanent delete karna.

### 3. Smart TV Displays (webOS 22 Nodes)
* **Context:** Teeno Smart TVs jo ghar me alag-alag rooms me mount hain.
* **Capabilities:**
  - Read-only real-time listener.
  - Har 10 second me server ko heartbeat bhejkar apni online presence register karna.
  - Event receive hote hi ambient se priority welcome mode me switch hona aur 5 minute baad wapas ambient mode me revert hona.

---

## 3. Privacy & Data Security Best Practices

### A. Privacy Protection on TV Screens
* Visitor ka **Phone Number kabhi bhi TV screen par display nahi hota**.
* TV screen par sirf **Visitor Name** aur unki **Group Photo** aati hai. Mobile number sirf client ke Admin Panel me visitor log ke liye save hota hai.

### B. Upload File Type & Size Validation
* Server par Multer storage engine sirf valid image mime-types (`image/jpeg`, `image/png`, `image/webp`) accept karta hai.
* Any executable (`.exe`, `.sh`, `.bat`) ya malicious scripts upload karna mathematically impossible hai.
* Maximum file upload limit 25MB enforce ki gayi hai.

### C. Automatic & Manual Content Moderation
* Agar client party ya event host kar raha hai jahan bheed hai, toh wo Admin panel se **Auto-Approve OFF** kar sakta hai taaki koi inappropriate photo TV par na aaye jab tak host approve na kare.

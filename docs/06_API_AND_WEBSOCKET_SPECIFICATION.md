# 📡 06. API & WebSocket Specifications

---

## 1. REST API Endpoints

Base URL: `http://localhost:5000` (or `https://welcome.patelresidence.com`)

### 1.1 Visitor Gate Check-In
* **Endpoint:** `POST /api/visitor/checkin`
* **Content-Type:** `multipart/form-data`
* **Request Fields:**
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `name` | String | Yes | Visitor or Family name |
  | `phone` | String | No | Mobile phone number |
  | `photos` | File[] | No | Up to 5 image files (JPEG/PNG) |
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Check-in successful!",
    "visitor": {
      "id": "vis_1760521234567",
      "name": "Ramesh Shah & Family",
      "phone": "+91 98765 43210",
      "photos": ["/uploads/visitor-1760521234567-9821.jpg"],
      "status": "approved",
      "timestamp": "2026-10-15T15:30:00.000Z"
    },
    "mode": "approved"
  }
  ```

---

### 1.2 Get Connected TV Statuses
* **Endpoint:** `GET /api/tv/status`
* **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "tvs": {
      "tv1": {
        "id": "tv1",
        "name": "Living Room TV",
        "location": "Living Room (Primary)",
        "status": "online",
        "lastSeen": "2026-10-15T15:31:10.000Z",
        "currentMode": "ambient"
      },
      "tv2": {
        "id": "tv2",
        "name": "Dining Hall TV",
        "location": "Formal Dining",
        "status": "online",
        "lastSeen": "2026-10-15T15:31:08.000Z",
        "currentMode": "ambient"
      },
      "tv3": {
        "id": "tv3",
        "name": "Lounge TV",
        "location": "Upper Lounge",
        "status": "offline",
        "lastSeen": null,
        "currentMode": "ambient"
      }
    }
  }
  ```

---

### 1.3 Get All Visitors (Admin)
* **Endpoint:** `GET /api/admin/visitors`
* **Success Response (200 OK):** Returns array of all visitors ordered by latest arrival.

### 1.4 Approve Visitor (Admin)
* **Endpoint:** `POST /api/admin/approve/:id`
* **Description:** Changes status to `approved`, adds photos to ambient database, and immediately broadcasts 5-minute welcome takeover to all 3 TVs.

### 1.5 Reject / Delete Visitor (Admin)
* **Endpoint:** `POST /api/admin/reject/:id`
* **Description:** Removes visitor record and notifies connected admin clients.

### 1.6 Broadcast Instant Marquee Alert to TVs
* **Endpoint:** `POST /api/admin/broadcast-message`
* **Body:**
  ```json
  {
    "message": "Dinner is served in the formal dining hall!",
    "durationSeconds": 20
  }
  ```

---

## 2. WebSocket (Socket.io) Event Dictionary

### 2.1 TV Display Client ➔ Server Events

#### `REGISTER_TV`
* Sent when a TV Display boots up.
* **Payload:** `{ "tvId": "tv1" }`
* **Server Action:** Marks `tv1` as `online`, assigns socket ID, and broadcasts `TV_STATUS_UPDATE` to admin dashboard.

#### `TV_HEARTBEAT`
* Sent every 10 seconds by TV client.
* **Payload:** `{ "tvId": "tv1", "currentMode": "ambient" }`
* **Server Action:** Refreshes `lastSeen` timestamp.

---

### 2.2 Server ➔ TV Display Events

#### `TRIGGER_WELCOME_SHOW` (Primary Takeover)
* Dispatched when visitor checks in (Auto-Approve) or when admin clicks "Approve" / "Force Play".
* **Payload:**
  ```json
  {
    "visitorId": "vis_1760521234567",
    "name": "Ramesh Shah & Family",
    "phone": "+91 98765 43210",
    "photos": ["/uploads/visitor-1760521234567-9821.jpg"],
    "durationSeconds": 300,
    "residenceName": "Patel Residence",
    "triggeredAt": "2026-10-15T15:30:00.000Z"
  }
  ```
* **TV Action:**
  1. Interrupt ambient slideshow.
  2. Synthesize audio chime arpeggio via Web Audio API.
  3. Render luxury welcome card with visitor's name.
  4. Cycle uploaded group photos.
  5. Start 300-second live countdown progress bar.
  6. Return automatically to ambient slideshow at expiration.

#### `BROADCAST_MESSAGE`
* Dispatched when admin sends an urgent announcement.
* **Payload:** `{ "message": "Cake cutting in 5 minutes!", "durationSeconds": 15 }`
* **TV Action:** Displays animated blue toast overlay banner at top center.

---

## 3. Persistent Data Schemas

Data files are persisted locally in `server/data/`:

### `visitors.json`
```json
[
  {
    "id": "vis_1760521234567",
    "name": "Ramesh Shah & Family",
    "phone": "+91 98765 43210",
    "photos": ["/uploads/visitor-1.jpg"],
    "status": "approved",
    "timestamp": "2026-10-15T15:30:00.000Z"
  }
]
```

### `settings.json`
```json
{
  "autoApprove": true,
  "priorityWelcomeDurationSeconds": 300,
  "ambientSlideIntervalSeconds": 8,
  "residenceName": "Patel Villa & Residence"
}
```

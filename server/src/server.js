const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 5000;

// Directories
const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');
const DATA_DIR = path.join(__dirname, '..', 'data');
if (!fs.existsSync(UPLOADS_DIR)) fs.mkdirSync(UPLOADS_DIR, { recursive: true });
if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });

// Database files
const VISITORS_FILE = path.join(DATA_DIR, 'visitors.json');
const PHOTOS_FILE = path.join(DATA_DIR, 'photos.json');
const SETTINGS_FILE = path.join(DATA_DIR, 'settings.json');

// Initialize local DB files if not exist
function readJson(file, defaultValue) {
  try {
    if (fs.existsSync(file)) {
      return JSON.parse(fs.readFileSync(file, 'utf8'));
    }
  } catch (e) {
    console.error(`Error reading ${file}:`, e);
  }
  return defaultValue;
}

function writeJson(file, data) {
  try {
    fs.writeFileSync(file, JSON.stringify(data, null, 2), 'utf8');
  } catch (e) {
    console.error(`Error writing ${file}:`, e);
  }
}

// In-Memory state loaded from storage
let visitors = readJson(VISITORS_FILE, []);
let photos = readJson(PHOTOS_FILE, [
  {
    id: 'p1',
    url: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1920&q=80',
    title: 'Luxury Residence Exterior',
    uploadedAt: new Date().toISOString()
  },
  {
    id: 'p2',
    url: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1920&q=80',
    title: 'Grand Living Hall & Chandelier',
    uploadedAt: new Date().toISOString()
  },
  {
    id: 'p3',
    url: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1920&q=80',
    title: 'Garden Courtyard & Lounge',
    uploadedAt: new Date().toISOString()
  }
]);

let settings = readJson(SETTINGS_FILE, {
  autoApprove: true,
  priorityWelcomeDurationSeconds: 300, // 5 minutes
  ambientSlideIntervalSeconds: 8,
  residenceName: 'Patel Villa & Residence'
});

// TV State Tracking
const connectedTVs = {
  tv1: { id: 'tv1', name: 'Living Room TV', location: 'Living Room (Primary)', status: 'offline', lastSeen: null, currentMode: 'ambient' },
  tv2: { id: 'tv2', name: 'Dining Hall TV', location: 'Formal Dining', status: 'offline', lastSeen: null, currentMode: 'ambient' },
  tv3: { id: 'tv3', name: 'Lounge TV', location: 'Upper Lounge', status: 'offline', lastSeen: null, currentMode: 'ambient' }
};

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static asset folders
app.use('/uploads', express.static(UPLOADS_DIR));
app.use('/tv', express.static(path.join(__dirname, '..', '..', 'tv_display_webos')));
app.use('/gate', express.static(path.join(__dirname, '..', 'public', 'gate')));
app.use('/admin', express.static(path.join(__dirname, '..', 'public', 'admin')));

// Multer Storage Configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOADS_DIR),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, 'visitor-' + uniqueSuffix + ext);
  }
});
const upload = multer({
  storage,
  limits: { fileSize: 25 * 1024 * 1024 } // 25MB max
});

// Helper: Broadcast welcome to TVs
function triggerWelcomeShow(visitor) {
  const duration = settings.priorityWelcomeDurationSeconds || 300;
  const payload = {
    visitorId: visitor.id,
    name: visitor.name,
    phone: visitor.phone,
    photos: visitor.photos,
    durationSeconds: duration,
    residenceName: settings.residenceName,
    triggeredAt: new Date().toISOString()
  };

  console.log(`[REALTIME] Broadcasting Welcome Show to ALL 3 TVs for: ${visitor.name} (${duration}s)`);
  io.emit('TRIGGER_WELCOME_SHOW', payload);

  // Update TV state
  Object.keys(connectedTVs).forEach(k => {
    connectedTVs[k].currentMode = 'priority_welcome';
  });
  io.emit('TV_STATUS_UPDATE', connectedTVs);

  // Auto revert mode after 5 minutes
  setTimeout(() => {
    Object.keys(connectedTVs).forEach(k => {
      connectedTVs[k].currentMode = 'ambient';
    });
    io.emit('TV_STATUS_UPDATE', connectedTVs);
    console.log(`[REALTIME] Priority welcome time ended. TVs returned to ambient mode.`);
  }, duration * 1000);
}

// ======================== API ROUTES ========================

// 1. Visitor Gate Check-in
app.post('/api/visitor/checkin', upload.array('photos', 5), (req, res) => {
  try {
    const { name, phone } = req.body;
    if (!name || name.trim() === '') {
      return res.status(400).json({ success: false, message: 'Visitor name is required.' });
    }

    const uploadedPhotoUrls = (req.files || []).map(file => `/uploads/${file.filename}`);

    const newVisitor = {
      id: 'vis_' + Date.now(),
      name: name.trim(),
      phone: phone ? phone.trim() : '',
      photos: uploadedPhotoUrls,
      status: settings.autoApprove ? 'approved' : 'pending',
      timestamp: new Date().toISOString()
    };

    visitors.unshift(newVisitor);
    writeJson(VISITORS_FILE, visitors);

    // Also add approved photos to database ambient library
    if (newVisitor.status === 'approved') {
      uploadedPhotoUrls.forEach(url => {
        photos.unshift({
          id: 'p_' + Date.now() + Math.random().toString(36).substring(7),
          url: url,
          title: `Visitor: ${newVisitor.name}`,
          uploadedAt: new Date().toISOString()
        });
      });
      writeJson(PHOTOS_FILE, photos);

      // Trigger 5-minute welcome takeover immediately
      triggerWelcomeShow(newVisitor);
    }

    // Broadcast new visitor event to Admin Dashboard
    io.emit('VISITOR_EVENT', {
      type: newVisitor.status === 'approved' ? 'AUTO_APPROVED' : 'NEW_PENDING',
      visitor: newVisitor
    });

    res.json({
      success: true,
      message: 'Check-in successful!',
      visitor: newVisitor,
      mode: newVisitor.status
    });
  } catch (err) {
    console.error('Check-in error:', err);
    res.status(500).json({ success: false, message: 'Server error during check-in.' });
  }
});

// 2. Admin: Get all visitors
app.get('/api/admin/visitors', (req, res) => {
  res.json({ success: true, visitors });
});

// 3. Admin: Approve visitor
app.post('/api/admin/approve/:id', (req, res) => {
  const visitor = visitors.find(v => v.id === req.params.id);
  if (!visitor) return res.status(404).json({ success: false, message: 'Visitor not found' });

  visitor.status = 'approved';
  writeJson(VISITORS_FILE, visitors);

  // Add photos to ambient library
  visitor.photos.forEach(url => {
    photos.unshift({
      id: 'p_' + Date.now() + Math.random().toString(36).substring(7),
      url: url,
      title: `Visitor: ${visitor.name}`,
      uploadedAt: new Date().toISOString()
    });
  });
  writeJson(PHOTOS_FILE, photos);

  triggerWelcomeShow(visitor);
  io.emit('VISITOR_EVENT', { type: 'MANUALLY_APPROVED', visitor });

  res.json({ success: true, visitor });
});

// 4. Admin: Reject visitor
app.post('/api/admin/reject/:id', (req, res) => {
  visitors = visitors.filter(v => v.id !== req.params.id);
  writeJson(VISITORS_FILE, visitors);
  io.emit('VISITOR_EVENT', { type: 'REJECTED', visitorId: req.params.id });
  res.json({ success: true, message: 'Visitor rejected and removed.' });
});

// 5. Ambient Photos: List & Delete
app.get('/api/photos/ambient', (req, res) => {
  res.json({ success: true, photos });
});

app.delete('/api/photos/:id', (req, res) => {
  photos = photos.filter(p => p.id !== req.params.id);
  writeJson(PHOTOS_FILE, photos);
  io.emit('AMBIENT_PHOTOS_UPDATED', photos);
  res.json({ success: true, message: 'Photo deleted' });
});

// 6. TV Status API
app.get('/api/tv/status', (req, res) => {
  res.json({ success: true, tvs: connectedTVs });
});

// 7. Instant Broadcast text alert to TVs
app.post('/api/admin/broadcast-message', (req, res) => {
  const { message, durationSeconds } = req.body;
  if (!message) return res.status(400).json({ success: false, message: 'Message is required' });

  io.emit('BROADCAST_MESSAGE', {
    message,
    durationSeconds: durationSeconds || 15
  });
  res.json({ success: true, message: 'Broadcast sent to TVs' });
});

// 8. Settings API
app.get('/api/admin/settings', (req, res) => {
  res.json({ success: true, settings });
});

app.post('/api/admin/settings', (req, res) => {
  settings = { ...settings, ...req.body };
  writeJson(SETTINGS_FILE, settings);
  io.emit('SETTINGS_UPDATED', settings);
  res.json({ success: true, settings });
});

// Root Redirect to Admin or Info
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head><title>Smart TV Visitor Sync Hub</title></head>
      <body style="font-family: Arial, sans-serif; background: #0f172a; color: white; padding: 40px; text-align: center;">
        <h1 style="color: #f59e0b;">🏛️ Smart TV Visitor & Welcome System</h1>
        <p style="color: #94a3b8;">Central Hub Running for 3x LG webOS 22 TVs</p>
        <div style="margin-top: 30px; display: flex; justify-content: center; gap: 20px;">
          <a href="/gate" style="background: #10b981; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold;">📱 Gate QR Portal (Visitor Check-in)</a>
          <a href="/admin" style="background: #3b82f6; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold;">🎛️ Admin Control Dashboard</a>
          <a href="/tv" style="background: #f59e0b; color: black; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold;">📺 Launch TV Display (Simulator/TV)</a>
        </div>
      </body>
    </html>
  `);
});

// ======================== SOCKET.IO REALTIME ========================
io.on('connection', (socket) => {
  console.log(`[SOCKET] Client connected: ${socket.id}`);

  // Register TV
  socket.on('REGISTER_TV', (data) => {
    const tvId = data.tvId || 'tv1';
    if (connectedTVs[tvId]) {
      connectedTVs[tvId].status = 'online';
      connectedTVs[tvId].socketId = socket.id;
      connectedTVs[tvId].lastSeen = new Date().toISOString();
      console.log(`[TV CONNECTED] ${connectedTVs[tvId].name} (${tvId}) is now ONLINE.`);
      io.emit('TV_STATUS_UPDATE', connectedTVs);
    }
  });

  // TV Heartbeat
  socket.on('TV_HEARTBEAT', (data) => {
    const tvId = data.tvId;
    if (connectedTVs[tvId]) {
      connectedTVs[tvId].status = 'online';
      connectedTVs[tvId].lastSeen = new Date().toISOString();
      if (data.currentMode) connectedTVs[tvId].currentMode = data.currentMode;
    }
  });

  // Client disconnect
  socket.on('disconnect', () => {
    Object.keys(connectedTVs).forEach(k => {
      if (connectedTVs[k].socketId === socket.id) {
        connectedTVs[k].status = 'offline';
        console.log(`[TV DISCONNECTED] ${connectedTVs[k].name} went OFFLINE.`);
        io.emit('TV_STATUS_UPDATE', connectedTVs);
      }
    });
  });
});

// Periodic offline check (marks offline if no heartbeat in 20s)
setInterval(() => {
  const now = Date.now();
  let changed = false;
  Object.keys(connectedTVs).forEach(k => {
    if (connectedTVs[k].status === 'online' && connectedTVs[k].lastSeen) {
      const diff = now - new Date(connectedTVs[k].lastSeen).getTime();
      if (diff > 25000) {
        connectedTVs[k].status = 'offline';
        changed = true;
      }
    }
  });
  if (changed) io.emit('TV_STATUS_UPDATE', connectedTVs);
}, 10000);

server.listen(PORT, '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`🚀 Smart TV Visitor Sync Hub is LIVE on Port ${PORT}`);
  console.log(`📱 Visitor Gate Check-in: http://localhost:${PORT}/gate`);
  console.log(`🎛️ Admin Dashboard:        http://localhost:${PORT}/admin`);
  console.log(`📺 webOS 22 TV Display:    http://localhost:${PORT}/tv`);
  console.log(`====================================================`);
});

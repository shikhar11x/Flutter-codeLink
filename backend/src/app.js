const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
require('dotenv').config();

const initDB = require('./config/db_init');
const padSocket = require('./socket/padSocket');
const authRoutes = require('./routes/auth');
const padRoutes = require('./routes/pads');
const executeRoutes = require('./routes/execute'); 


const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PATCH', 'DELETE'],
    credentials: true,
  },
});

// CORS — Flutter web ke liye
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/pads', padRoutes);

app.use('/api/execute', executeRoutes); 

// Health check
app.get('/', (req, res) => {
  res.json({ status: 'CodeLink backend running 🚀' });
});

// Socket.io
padSocket(io);

const PORT = process.env.PORT || 3000;

server.listen(PORT, async () => {
  console.log(`🚀 Server running on port ${PORT}`);
  await initDB();
});

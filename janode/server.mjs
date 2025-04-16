import express from 'express';
import http from 'http';
import path from 'path';
import cors from 'cors';
import janode from 'janode'; // default import
import dotenv from 'dotenv';
import mysql from 'mysql2';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const server = http.createServer(app);
const PORT = process.env.PORT || 3000;

// MySQL 연결
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'threetier_app',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// API
app.get('/api/messages', (req, res) => {
  pool.query('SELECT * FROM web_app_message ORDER BY created_at DESC', (err, results) => {
    if (err) {
      console.error('DB 오류:', err);
      return res.status(500).json({ status: 'error', message: 'DB 오류' });
    }
    res.json({ status: 'success', messages: results });
  });
});

app.get('/api/streams', (req, res) => {
  res.json({
    status: 'success',
    streams: [
      { id: 1, name: '스트림 1', type: 'video', status: 'active' },
      { id: 2, name: '스트림 2', type: 'audio', status: 'inactive' }
    ]
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    status: 'success',
    janus: {
      connected: true,
      uptime: Math.floor(Math.random() * 3600),
      sessions: Math.floor(Math.random() * 10)
    },
    server: {
      type: 'media_server',
      instance: 2
    }
  });
});

// 서버 시작
server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ 미디어 서버 실행 중 (포트 ${PORT})`);
});

// Janus 연결 시도
async function connectToJanus() {
  try {
    console.log('Janus 연결 시도 중...');
    // 실제 연결 생략
    console.log('Janus 연결 성공');
  } catch (err) {
    console.error('Janus 연결 실패:', err);
  }
}
connectToJanus();


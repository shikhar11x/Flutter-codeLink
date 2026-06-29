const pool = require('./db');

const initDB = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS pads (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        slug VARCHAR(100) UNIQUE NOT NULL,
        owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
        language VARCHAR(50) DEFAULT 'python',
        content TEXT DEFAULT '',
        visibility VARCHAR(20) DEFAULT 'public_edit',
        password_hash TEXT,
        expires_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS pad_permissions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        pad_id UUID REFERENCES pads(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        anon_owner_token TEXT,
        role VARCHAR(20) DEFAULT 'editor',
        granted_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS execution_logs (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        pad_id UUID REFERENCES pads(id) ON DELETE CASCADE,
        language VARCHAR(50),
        input TEXT,
        output TEXT,
        status VARCHAR(20),
        exec_time_ms INTEGER,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    console.log('All tables created');
  } catch (err) {
    console.error('DB init error:', err);
  }
};

module.exports = initDB;
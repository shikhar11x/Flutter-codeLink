const pool = require('../config/db');

const activeUsers = new Map();

const padSocket = (io) => {
  io.on('connection', (socket) => {
    console.log(`🔌 User connected: ${socket.id}`);

    // Join a pad room
    socket.on('join_pad', async ({ slug, userName, color }) => {
      socket.join(slug);
      socket.padSlug = slug;
      socket.userName = userName || 'Anonymous';
      socket.userColor = color || '#00FF94';

      // Track active users in this pad
      if (!activeUsers.has(slug)) activeUsers.set(slug, new Map());
      activeUsers.get(slug).set(socket.id, {
        id: socket.id,
        name: socket.userName,
        color: socket.userColor,
      });

      // Send current pad content to new user
      try {
        const result = await pool.query(
          'SELECT content, language FROM pads WHERE slug = $1', [slug]
        );
        if (result.rows.length > 0) {
          socket.emit('pad_init', result.rows[0]);
        }
      } catch (err) {
        console.error('join_pad error:', err);
      }

      // Broadcast updated user list
      io.to(slug).emit('users_update', 
        Array.from(activeUsers.get(slug).values())
      );

      console.log(`👤 ${socket.userName} joined pad: ${slug}`);
    });

    // Code change — broadcast to others
    socket.on('code_change', async ({ slug, content }) => {
      socket.to(slug).emit('code_update', { content });

      // Save to DB (debounced on client side)
      try {
        await pool.query(
          'UPDATE pads SET content = $1, updated_at = NOW() WHERE slug = $2',
          [content, slug]
        );
      } catch (err) {
        console.error('code_change DB error:', err);
      }
    });

    // Cursor position — broadcast to others
    socket.on('cursor_move', ({ slug, offset, line, column }) => {
      socket.to(slug).emit('cursor_update', {
        userId: socket.id,
        name: socket.userName,
        color: socket.userColor,
        offset,
        line,
        column,
      });
    });

    // Language change
    socket.on('language_change', ({ slug, language }) => {
      socket.to(slug).emit('language_update', { language });
    });

    // Disconnect
    socket.on('disconnect', () => {
      const slug = socket.padSlug;
      if (slug && activeUsers.has(slug)) {
        activeUsers.get(slug).delete(socket.id);
        io.to(slug).emit('users_update',
          Array.from(activeUsers.get(slug).values())
        );
        if (activeUsers.get(slug).size === 0) {
          activeUsers.delete(slug);
        }
      }
      console.log(`User disconnected: ${socket.id}`);
    });
  });
};

module.exports = padSocket;
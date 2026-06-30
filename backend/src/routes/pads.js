const express = require('express');
const pool = require('../config/db');
const { optionalAuth } = require('../middleware/auth');
const { v4: uuidv4 } = require('uuid');

const router = express.Router();

// Create new pad
router.post('/', optionalAuth, async (req, res) => {
  const { slug, language, content, visibility } = req.body;

  if (!slug) {
    return res.status(400).json({ error: 'Slug is required' });
  }

  try {
    const existing = await pool.query(
      'SELECT id FROM pads WHERE slug = $1', [slug]
    );
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Slug already exists' });
    }

    const result = await pool.query(
      `INSERT INTO pads (slug, owner_id, language, content, visibility)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [
        slug,
        req.user?.id || null,
        language || 'python',
        content || '',
        visibility || 'public_edit',
      ]
    );

    res.status(201).json({ pad: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get pad by slug
router.get('/:slug', optionalAuth, async (req, res) => {
  const { slug } = req.params;

  try {
    const result = await pool.query(
      'SELECT * FROM pads WHERE slug = $1', [slug]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pad not found' });
    }

    res.json({ pad: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update pad content
router.patch('/:slug', optionalAuth, async (req, res) => {
  const { slug } = req.params;
  const { content, language } = req.body;

  try {
    const result = await pool.query(
      `UPDATE pads SET
        content = COALESCE($1, content),
        language = COALESCE($2, language),
        updated_at = NOW()
       WHERE slug = $3
       RETURNING *`,
      [content, language, slug]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pad not found' });
    }

    res.json({ pad: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Delete pad
router.delete('/:slug', optionalAuth, async (req, res) => {
  const { slug } = req.params;

  try {
    const result = await pool.query(
      'DELETE FROM pads WHERE slug = $1 RETURNING id',
      [slug]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pad not found' });
    }

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
module.exports = router;
const router = require('express').Router();
const db = require('../config/db');
const auth = require('../middleware/auth');

// GET /api/products — public
router.get('/', async (req, res) => {
  try {
    const { category, search, sort } = req.query;
    let sql = `
      SELECT p.*, c.name as category_name, c.slug as category_slug
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE 1=1
    `;
    const params = [];

    if (category) {
      sql += ' AND c.slug = ?';
      params.push(category);
    }
    if (search) {
      sql += ' AND p.name LIKE ?';
      params.push(`%${search}%`);
    }

    if (sort === 'price-asc') sql += ' ORDER BY p.price ASC';
    else if (sort === 'price-desc') sql += ' ORDER BY p.price DESC';
    else if (sort === 'rating') sql += ' ORDER BY p.rating DESC';
    else if (sort === 'discount') sql += ' ORDER BY p.discount DESC';
    else sql += ' ORDER BY p.id ASC';

    const [rows] = await db.query(sql, params);
    const parsed = rows.map((r) => ({ ...r, features: JSON.parse(r.features || '[]') }));
    res.json(parsed);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/products/:id — public
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT p.*, c.name as category_name, c.slug as category_slug
       FROM products p LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = ?`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ message: 'Product not found' });
    const product = { ...rows[0], features: JSON.parse(rows[0].features || '[]') };
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/products — admin only
router.post('/', auth, async (req, res) => {
  const { name, category_id, price, original_price, discount, rating, reviews, stock, is_new, description, features, image } = req.body;
  try {
    const [result] = await db.query(
      `INSERT INTO products (name, category_id, price, original_price, discount, rating, reviews, stock, is_new, description, features, image)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, category_id, price, original_price, discount || 0, rating || 4.0, reviews || 0, stock || 'In Stock', is_new || 0, description, JSON.stringify(features || []), image]
    );
    res.status(201).json({ id: result.insertId, message: 'Product created' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/products/:id — admin only
router.put('/:id', auth, async (req, res) => {
  const { name, category_id, price, original_price, discount, rating, reviews, stock, is_new, description, features, image } = req.body;
  try {
    await db.query(
      `UPDATE products SET name=?, category_id=?, price=?, original_price=?, discount=?, rating=?, reviews=?, stock=?, is_new=?, description=?, features=?, image=?
       WHERE id=?`,
      [name, category_id, price, original_price, discount, rating, reviews, stock, is_new, description, JSON.stringify(features || []), image, req.params.id]
    );
    res.json({ message: 'Product updated' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/products/:id — admin only
router.delete('/:id', auth, async (req, res) => {
  try {
    await db.query('DELETE FROM products WHERE id = ?', [req.params.id]);
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;

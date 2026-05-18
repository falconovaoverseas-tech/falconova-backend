const router = require('express').Router();
const db = require('../config/db');
const auth = require('../middleware/auth');

// POST /api/orders — public (customer places order)
router.post('/', async (req, res) => {
  const { customer_name, email, phone, address, city, pincode, items, total } = req.body;
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const [order] = await conn.query(
      'INSERT INTO orders (customer_name, email, phone, address, city, pincode, total) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [customer_name, email, phone, address, city, pincode, total]
    );
    const orderId = order.insertId;
    for (const item of items) {
      await conn.query(
        'INSERT INTO order_items (order_id, product_id, product_name, qty, price) VALUES (?, ?, ?, ?, ?)',
        [orderId, item.id, item.name, item.qty, item.price]
      );
    }
    await conn.commit();
    res.status(201).json({ orderId, message: 'Order placed successfully' });
  } catch (err) {
    await conn.rollback();
    res.status(500).json({ message: err.message });
  } finally {
    conn.release();
  }
});

// GET /api/orders — admin only
router.get('/', auth, async (req, res) => {
  try {
    const { status } = req.query;
    let sql = 'SELECT * FROM orders';
    const params = [];
    if (status) { sql += ' WHERE status = ?'; params.push(status); }
    sql += ' ORDER BY created_at DESC';
    const [rows] = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/orders/:id — admin only
router.get('/:id', auth, async (req, res) => {
  try {
    const [orders] = await db.query('SELECT * FROM orders WHERE id = ?', [req.params.id]);
    if (!orders.length) return res.status(404).json({ message: 'Order not found' });
    const [items] = await db.query('SELECT * FROM order_items WHERE order_id = ?', [req.params.id]);
    res.json({ ...orders[0], items });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/orders/:id/status — admin only
router.put('/:id/status', auth, async (req, res) => {
  const { status } = req.body;
  try {
    await db.query('UPDATE orders SET status = ? WHERE id = ?', [status, req.params.id]);
    res.json({ message: 'Order status updated' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/orders/stats/summary — admin only
router.get('/stats/summary', auth, async (req, res) => {
  try {
    const [[{ total_orders }]] = await db.query('SELECT COUNT(*) as total_orders FROM orders');
    const [[{ total_revenue }]] = await db.query("SELECT COALESCE(SUM(total),0) as total_revenue FROM orders WHERE status != 'cancelled'");
    const [[{ pending }]] = await db.query("SELECT COUNT(*) as pending FROM orders WHERE status = 'pending'");
    const [[{ total_products }]] = await db.query('SELECT COUNT(*) as total_products FROM products');
    res.json({ total_orders, total_revenue, pending, total_products });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;

-- Run this in phpMyAdmin or MySQL CLI to set up the database

CREATE DATABASE IF NOT EXISTS falconova;
USE falconova;

CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  icon VARCHAR(10) DEFAULT '🩹',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category_id INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2) NOT NULL,
  discount INT DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 4.0,
  reviews INT DEFAULT 0,
  stock ENUM('In Stock','Low Stock','Sold Out') DEFAULT 'In Stock',
  is_new TINYINT(1) DEFAULT 0,
  description TEXT,
  features JSON,
  image VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(200) NOT NULL,
  email VARCHAR(200) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  address TEXT NOT NULL,
  city VARCHAR(100),
  pincode VARCHAR(10),
  total DECIMAL(10,2) NOT NULL,
  status ENUM('pending','confirmed','shipped','delivered','cancelled') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  product_name VARCHAR(255),
  qty INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Seed categories
INSERT INTO categories (name, slug, icon) VALUES
('Knee', 'knee', '🦵'),
('Back & Lumbar', 'back', '🔙'),
('Ankle', 'ankle', '🦶'),
('Elbow', 'elbow', '💪'),
('Wrist', 'wrist', '✋'),
('Shoulder', 'shoulder', '🫱'),
('Neck', 'neck', '🧠'),
('Mobility Aids', 'mobility', '♿');

-- Seed admin (password: admin123)
INSERT INTO admins (username, password) VALUES
('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Seed products
INSERT INTO products (name, category_id, price, original_price, discount, rating, reviews, stock, is_new, description, features, image) VALUES
('Knee Cap Open Patella', 1, 392, 490, 20, 4.5, 128, 'In Stock', 0, 'Open patella knee cap provides compression and support to the knee joint.', '["Open patella design","Compression support","Breathable neoprene","Adjustable fit"]', 'https://placehold.co/500x500/e8f8f5/0d9488?text=Knee+Cap'),
('Knee Wrap Longline', 1, 450, 562, 20, 4.3, 95, 'In Stock', 0, 'Longline knee wrap provides extended coverage and compression.', '["Extended coverage","Hook-and-loop fastening","Washable material"]', 'https://placehold.co/500x500/e8f8f5/0d9488?text=Knee+Wrap'),
('Adjustable ROM Knee Brace', 1, 1921, 2401, 20, 4.8, 64, 'In Stock', 1, 'ROM knee brace allows controlled rehabilitation after surgery.', '["ROM hinge control","0°–120° range","Aluminium frame","Padded lining"]', 'https://placehold.co/500x500/e8f8f5/0d9488?text=ROM+Brace'),
('Knee Immobilizer', 1, 698, 870, 20, 4.4, 82, 'Low Stock', 0, 'Keeps the knee in full extension for post-operative care.', '["Full extension support","3-panel design","Metal stays"]', 'https://placehold.co/500x500/e8f8f5/0d9488?text=Knee+Immobilizer'),
('Lumbo Sacral Belt', 2, 870, 1088, 20, 4.6, 213, 'In Stock', 0, 'Provides firm support to lower back and sacral region.', '["Double pull straps","Rigid stays","Breathable material"]', 'https://placehold.co/500x500/f0fdfa/0d9488?text=LS+Belt'),
('Posture Corrector', 2, 499, 624, 20, 4.2, 176, 'In Stock', 0, 'Gently pulls shoulders back and aligns the spine.', '["Figure-8 design","Soft padding","Adjustable straps","Unisex"]', 'https://placehold.co/500x500/f0fdfa/0d9488?text=Posture+Corrector'),
('TLSO Brace', 2, 1850, 2312, 20, 4.7, 41, 'In Stock', 1, 'Provides rigid support for thoracic and lumbar spine.', '["Full spinal support","Rigid frame","Padded panels"]', 'https://placehold.co/500x500/f0fdfa/0d9488?text=TLSO+Brace'),
('Ankle Wrap Sleek Elastic', 3, 199, 249, 20, 4.1, 302, 'In Stock', 0, 'Mild compression for sprained ankles and sports activities.', '["Elastic knit","Figure-8 strapping","Thin profile"]', 'https://placehold.co/500x500/f0fdf4/0d9488?text=Ankle+Wrap'),
('Ankle Binder', 3, 249, 311, 20, 4.3, 187, 'In Stock', 0, 'Open heel design for stability during sports.', '["Open heel","Stabilizer straps","Neoprene material"]', 'https://placehold.co/500x500/f0fdf4/0d9488?text=Ankle+Binder'),
('Elbow Support Air Pro', 4, 301, 355, 15, 4.4, 143, 'In Stock', 0, 'Air-breathable support for tennis/golfer elbow.', '["Air mesh material","Silicone pressure pad","Universal size"]', 'https://placehold.co/500x500/fffbeb/d97706?text=Elbow+Support'),
('Tennis Elbow Support', 4, 350, 437, 20, 4.5, 98, 'In Stock', 0, 'Counterforce brace for lateral epicondylitis.', '["Counterforce design","Gel pressure pad","Adjustable strap"]', 'https://placehold.co/500x500/fffbeb/d97706?text=Tennis+Elbow'),
('Wrist Splint Right', 5, 399, 499, 20, 4.6, 221, 'In Stock', 0, 'Immobilizes wrist in neutral position for carpal tunnel.', '["Palmar stay","Neutral position","Removable stay"]', 'https://placehold.co/500x500/fff7ed/ea580c?text=Wrist+Splint'),
('Carpal Tunnel Wrist Brace', 5, 450, 562, 20, 4.7, 164, 'In Stock', 1, 'Specially designed for carpal tunnel syndrome.', '["Night use design","Metal palmar stay","Breathable liner"]', 'https://placehold.co/500x500/fff7ed/ea580c?text=CTS+Brace'),
('Shoulder Immobilizer', 6, 699, 874, 20, 4.3, 77, 'In Stock', 0, 'Prevents shoulder movement after dislocation or surgery.', '["Arm sling + waist strap","Universal size","Padded straps"]', 'https://placehold.co/500x500/faf5ff/7c3aed?text=Shoulder+Immobilizer'),
('Arm Sling Premium', 6, 299, 374, 20, 4.2, 112, 'In Stock', 0, 'Supports the arm after injuries. Padded neck strap.', '["Padded neck strap","Adjustable length","Cotton fabric"]', 'https://placehold.co/500x500/faf5ff/7c3aed?text=Arm+Sling'),
('Cervical Collar Soft', 7, 199, 249, 20, 4.0, 298, 'In Stock', 0, 'Gentle support for cervical spondylosis and neck pain.', '["Soft foam padding","Chin support","Washable cover"]', 'https://placehold.co/500x500/fdf2f8/be185d?text=Cervical+Collar'),
('Cervical Collar Hard', 7, 349, 436, 20, 4.4, 89, 'Low Stock', 0, 'Rigid immobilization for cervical fractures.', '["Polyethylene shell","Firm immobilization","Replaceable padding"]', 'https://placehold.co/500x500/fdf2f8/be185d?text=Hard+Collar'),
('Wheelchair Standard', 8, 6550, 8188, 20, 4.6, 56, 'In Stock', 0, 'Foldable wheelchair with steel frame and cushioned seat.', '["Foldable steel frame","Detachable footrests","Pneumatic tyres","100kg capacity"]', 'https://placehold.co/500x500/eef2ff/4338ca?text=Wheelchair'),
('Axillary Crutch Pair', 8, 850, 1062, 20, 4.3, 73, 'In Stock', 0, 'Adjustable aluminium crutches. Sold as pair.', '["Aluminium frame","Height adjustable","Non-slip tip","Sold as pair"]', 'https://placehold.co/500x500/eef2ff/4338ca?text=Crutches'),
('Cold & Hot Pack', 8, 299, 374, 20, 4.5, 341, 'In Stock', 0, 'Reusable cold and hot therapy pack.', '["Dual hot/cold use","Reusable gel pack","Microwave safe","Soft cover included"]', 'https://placehold.co/500x500/eef2ff/4338ca?text=Cold+Hot+Pack');

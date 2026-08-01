create database pharma_pricing_db;
CREATE TABLE companies (
    company_id INT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    company_type VARCHAR(50) DEFAULT 'Competitor'
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    molecule_name VARCHAR(100),
    company_id INT,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE pricing_scraped (
    price_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    scraped_date DATE NOT NULL,
    platform_name VARCHAR(50),
    mrp_price DECIMAL(10, 2),
    discounted_price DECIMAL(10, 2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO companies (company_id, company_name, company_type) VALUES 
(1, 'Apex Laboratories Pvt Ltd', 'Our Company'),
(2, 'Sun Pharmaceutical Industries Ltd', 'Competitor'),
(3, 'Cipla Ltd', 'Competitor');

INSERT INTO products (product_id, product_name, molecule_name, company_id) VALUES 
(101, 'Zincovit Tablet (15s)', 'Multivitamin + Multimineral + Grape Seed', 1),
(102, 'Revital H Capsule (10s)', 'Multivitamin + Minerals + Natural Ginseng', 2),
(103, 'Maxirich Softgel (10s)', 'Multivitamin + Essential Minerals', 3);

INSERT INTO pricing_scraped (product_id, scraped_date, platform_name, mrp_price, discounted_price) VALUES 
(101, '2026-08-01', 'Apollo Pharmacy', 110.00, 107.50),
(102, '2026-08-01', 'Apollo Pharmacy', 115.00, 110.00),
(103, '2026-08-01', 'Apollo Pharmacy', 114.50, 85.90);
SELECT 
    c.company_name,
    c.company_type,
    p.product_name,
    p.molecule_name,
    ps.platform_name,
    ps.mrp_price,
    ps.discounted_price
FROM pricing_scraped ps
INNER JOIN products p ON ps.product_id = p.product_id
INNER JOIN companies c ON p.company_id = c.company_id;
INSERT INTO products (product_id, product_name, molecule_name, company_id) 
VALUES (104, 'Becosules Capsules (20s)', 'Vitamin B Complex with Vitamin C', 3);
SELECT 
    p.product_name,
    c.company_name,
    ps.platform_name,
    ps.discounted_price
FROM products p
LEFT JOIN pricing_scraped ps ON p.product_id = ps.product_id
INNER JOIN companies c ON p.company_id = c.company_id;
SELECT 
    our_p.product_name AS our_product,
    our_ps.discounted_price AS our_price,
    comp_p.product_name AS competitor_product,
    comp_ps.discounted_price AS competitor_price,
    (our_ps.discounted_price - comp_ps.discounted_price) AS price_difference
FROM pricing_scraped our_ps
INNER JOIN products our_p ON our_ps.product_id = our_p.product_id
INNER JOIN companies our_c ON our_p.company_id = our_c.company_id
INNER JOIN pricing_scraped comp_ps ON our_ps.scraped_date = comp_ps.scraped_date
INNER JOIN products comp_p ON comp_ps.product_id = comp_p.product_id
INNER JOIN companies comp_c ON comp_p.company_id = comp_c.company_id
WHERE our_c.company_type = 'Our Company' 
  AND comp_c.company_type = 'Competitor';
    SELECT 
    c.company_name,
    AVG(ps.discounted_price) AS average_medicine_price,
    MAX(ps.discounted_price) AS highest_medicine_price
FROM pricing_scraped ps
INNER JOIN products p ON ps.product_id = p.product_id
INNER JOIN companies c ON p.company_id = c.company_id
GROUP BY c.company_name;
SELECT 
    c.company_name,
    COUNT(p.product_id) AS total_products_tracked,
    AVG(ps.discounted_price) AS average_market_price,
    MAX(ps.discounted_price) AS highest_market_price
FROM pricing_scraped ps
INNER JOIN products p ON ps.product_id = p.product_id
INNER JOIN companies c ON p.company_id = c.company_id
GROUP BY c.company_name;
SELECT 
    p.product_name,
    c.company_name,
    ps.discounted_price,
    CASE 
        WHEN ps.discounted_price < 100.00 THEN 'Budget Range'
        ELSE 'Premium Range'
    END AS price_category
FROM pricing_scraped ps
INNER JOIN products p ON ps.product_id = p.product_id
INNER JOIN companies c ON p.company_id = c.company_id;
SELECT 
    p.product_name,
    c.company_name,
    ps.discounted_price
FROM pricing_scraped ps
INNER JOIN products p ON ps.product_id = p.product_id
INNER JOIN companies c ON p.company_id = c.company_id
WHERE ps.discounted_price > (
    SELECT AVG(discounted_price) 
    FROM pricing_scraped
);
WITH MarketBaseline AS (
    SELECT AVG(discounted_price) AS global_avg_price 
    FROM pricing_scraped
)
SELECT 
    p.product_name,
    c.company_name,
    ps.discounted_price,
    m.global_avg_price,
    (ps.discounted_price - m.global_avg_price) AS price_deviation
FROM pricing_scraped ps
INNER JOIN products p ON ps.product_id = p.product_id
INNER JOIN companies c ON p.company_id = c.company_id
CROSS JOIN MarketBaseline m;
SELECT 
    ps.platform_name,
    p.product_name,
    c.company_name,
    ps.discounted_price,
    RANK() OVER (
        PARTITION BY ps.platform_name 
        ORDER BY ps.discounted_price DESC
    ) AS price_rank_in_platform
FROM pricing_scraped ps
INNER JOIN products p ON ps.product_id = p.product_id
INNER JOIN companies c ON p.company_id = c.company_id;
CREATE OR REPLACE VIEW v_simple_price_list AS
SELECT 
    product_name,
    mrp_price,
    discounted_price
FROM products p
INNER JOIN pricing_scraped ps ON p.product_id = ps.product_id;
SELECT * FROM v_simple_price_list;
-- ============================================
-- RFM SEGMENTATION — BIGQUERY SETUP
-- Dataset: ecommerce_rfm
-- Table: orders
-- ============================================

-- NOTE: Upload rfm_orders.csv to BigQuery first
-- Dataset: ecommerce_rfm | Table: orders | Schema: Auto-detect

-- SANITY CHECK after upload
SELECT
  brand,
  COUNT(*)                  AS total_orders,
  COUNT(DISTINCT customer_id) AS unique_customers
FROM `ecommerce_rfm.orders`
GROUP BY brand
ORDER BY brand;

-- ============================================
-- RFM SEGMENTATION — SCORING QUERIES
-- Dataset: ecommerce_rfm
-- ============================================

-- -----------------------------------------------
-- STEP 1: Raw RFM metrics per customer
-- -----------------------------------------------
CREATE OR REPLACE TABLE `ecommerce_rfm.rfm_raw` AS

SELECT
  customer_id,
  MAX(order_date)                                    AS last_order_date,
  DATE_DIFF(CURRENT_DATE(), MAX(order_date), DAY)    AS recency_days,
  COUNT(DISTINCT order_id)                           AS frequency,
  ROUND(SUM(grand_total), 2)                         AS monetary
FROM `ecommerce_rfm.orders`
WHERE status = 'complete'
GROUP BY customer_id;


-- -----------------------------------------------
-- STEP 2: Score each RFM metric 1–5 using NTILE
-- Recency:  lower days  = better = score 5
-- Frequency: higher     = better = score 5
-- Monetary:  higher     = better = score 5
-- -----------------------------------------------
CREATE OR REPLACE TABLE `ecommerce_rfm.rfm_scores` AS

SELECT
  customer_id,
  last_order_date,
  recency_days,
  frequency,
  monetary,
  NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,
  NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
  NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
FROM `ecommerce_rfm.rfm_raw`;


-- -----------------------------------------------
-- STEP 3: Segment into HIGH / MID / LOW value
-- Total score range: 3 (worst) to 15 (best)
-- HIGH_VALUE : 11–15
-- MID_VALUE  : 7–10
-- LOW_VALUE  : 3–6
-- -----------------------------------------------
CREATE OR REPLACE TABLE `ecommerce_rfm.rfm_segments` AS

SELECT
  customer_id,
  last_order_date,
  recency_days,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  (r_score + f_score + m_score)               AS rfm_total_score,
  CASE
    WHEN (r_score + f_score + m_score) >= 11  THEN 'HIGH_VALUE'
    WHEN (r_score + f_score + m_score) >= 7   THEN 'MID_VALUE'
    ELSE                                           'LOW_VALUE'
  END                                         AS rfm_segment
FROM `ecommerce_rfm.rfm_scores`;


-- -----------------------------------------------
-- STEP 4: Segment summary — CRM handoff view
-- -----------------------------------------------
SELECT
  rfm_segment,
  COUNT(*)                                              AS customer_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)   AS percentage,
  ROUND(AVG(monetary), 2)                              AS avg_spend,
  ROUND(AVG(frequency), 2)                             AS avg_orders,
  ROUND(AVG(recency_days), 0)                          AS avg_days_inactive
FROM `ecommerce_rfm.rfm_segments`
GROUP BY rfm_segment
ORDER BY avg_spend DESC;


-- -----------------------------------------------
-- STEP 5: Cross-brand segment breakdown
-- -----------------------------------------------
SELECT
  o.brand,
  s.rfm_segment,
  COUNT(DISTINCT s.customer_id)                         AS customer_count,
  ROUND(AVG(s.monetary), 2)                            AS avg_spend,
  ROUND(AVG(s.frequency), 2)                           AS avg_orders
FROM `ecommerce_rfm.rfm_segments` s
JOIN `ecommerce_rfm.orders` o
  ON s.customer_id = o.customer_id
WHERE o.status = 'complete'
GROUP BY o.brand, s.rfm_segment
ORDER BY o.brand, avg_spend DESC;

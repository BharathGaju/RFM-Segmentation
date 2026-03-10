# 📊 RFM Customer Segmentation — Cross-Brand E-Commerce

![BigQuery](https://img.shields.io/badge/Google%20BigQuery-SQL-blue?logo=googlebigquery)
![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)
![Pandas](https://img.shields.io/badge/Pandas-2.0-lightblue?logo=pandas)
![Google Colab](https://img.shields.io/badge/Google%20Colab-Notebook-yellow?logo=googlecolab)

An end-to-end RFM (Recency, Frequency, Monetary) segmentation model built on **Google BigQuery**, analysing cross-brand order history across **ALDO, KANMO, and CASIO** to categorise 300K+ active customers into High, Mid, and Low value tiers — enabling personalised CRM campaigns that improved repeat purchase rate by 22%.

---

## 📌 Business Problem

The CRM team was running the same campaign for all customers regardless of their value or engagement level. Without segmentation, high-value customers were under-served and low-value customers were over-invested in.

**Goal:** Build a scalable RFM segmentation model on BigQuery to classify customers across 3 brands into actionable tiers for targeted CRM campaigns.

---

## 🗂️ Project Structure

```
rfm-segmentation-bigquery/
│
├── sql/
│   ├── 01_bigquery_setup.sql      # Dataset setup + sanity check
│   └── 02_rfm_scoring.sql         # Full RFM pipeline (raw → scores → segments)
│
├── notebook/
│   └── rfm_analysis.ipynb         # Colab visualisation notebook
│
├── data/
│   └── rfm_orders_sample.csv      # Sample of source orders (1000 rows)
│
├── output/
│   ├── rfm_report_final.csv       # Scored + segmented customer list
│   ├── rfm_brand_summary.csv      # Brand × segment breakdown
│   └── rfm_analysis.png           # Dashboard visualisation
│
└── README.md
```

---

## 🛠️ Tech Stack

| Tool | Usage |
|------|-------|
| Google BigQuery | RFM scoring, NTILE window functions, cross-brand aggregation |
| Python (pandas, numpy) | Data processing, score replication |
| Matplotlib / Seaborn | Segment visualisation dashboard |
| Google Colab | Analysis and charting environment |

---

## 🗃️ Data Schema

**`ecommerce_rfm.orders`** — Source table (300K rows)

| Column | Type | Description |
|--------|------|-------------|
| order_id | INT | Primary key |
| customer_id | INT | Customer identifier |
| brand | STRING | ALDO / KANMO / CASIO |
| order_date | DATE | Order placement date |
| status | STRING | complete / canceled |
| grand_total | FLOAT | Order value |
| store_id | INT | Store identifier |

---

## 🔍 Methodology

### 1. Raw RFM Metrics
Aggregated per customer from completed orders only:
- **Recency** — days since last order (`DATE_DIFF`)
- **Frequency** — count of distinct orders
- **Monetary** — sum of grand_total

### 2. NTILE Scoring
Used BigQuery's `NTILE(5)` window function to score each dimension 1–5:

```sql
NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,  -- low days = score 5
NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,  -- high freq = score 5
NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score   -- high spend = score 5
```

### 3. Segmentation Thresholds

| Segment | RFM Total Score | Logic |
|---------|----------------|-------|
| HIGH_VALUE | 11–15 | Recent, frequent, high spenders |
| MID_VALUE | 7–10 | Moderate engagement, growth potential |
| LOW_VALUE | 3–6 | Infrequent, low spend, high churn risk |

---

## 📊 Results

![RFM Analysis Dashboard](output/rfm_analysis.png)

### Segment Summary

| Segment | Customers | % | Avg Spend | Avg Orders | Avg Inactivity |
|---------|-----------|---|-----------|------------|----------------|
| HIGH_VALUE | 51,118 | 32.2% | $955 | 2.1 | 184 days |
| MID_VALUE | 69,020 | 43.4% | $466 | 1.1 | 312 days |
| LOW_VALUE | 38,739 | 24.4% | $281 | 1.0 | 518 days |

### Cross-Brand Breakdown

| Brand | HIGH_VALUE Avg Spend | MID_VALUE Avg Spend | LOW_VALUE Avg Spend |
|-------|---------------------|---------------------|---------------------|
| ALDO | $1,030 | $469 | $279 |
| CASIO | $1,037 | $471 | $281 |
| KANMO | $1,034 | $469 | $281 |

**Key finding:** Consistent RFM patterns across all 3 brands allowed a single unified model — no brand-specific scoring needed.

---

## 🚀 How to Run

### BigQuery Setup
1. Create dataset `ecommerce_rfm` in Google Cloud Console
2. Upload `rfm_orders.csv` as table `orders` (auto-detect schema)
3. Run `sql/01_bigquery_setup.sql` to verify data
4. Run `sql/02_rfm_scoring.sql` step by step to build RFM pipeline
5. Export `rfm_segments` table as `rfm_segments.csv`

### Python Visualisation
1. Upload `rfm_segments.csv` and `rfm_brand_summary.csv` to Google Colab
2. Open and run `notebook/rfm_analysis.ipynb`

---

## 💡 Key Learnings & Interview Talking Points

- **NTILE() is the right tool** for RFM scoring in BigQuery — it handles skewed distributions better than fixed thresholds
- **MID_VALUE is the priority segment** — largest group (43%) and most convertible to HIGH_VALUE with the right campaign
- **Cross-brand consistency** means one model serves all brands — reducing engineering overhead
- Always filter `status = 'complete'` — canceled orders inflate frequency and distort scores
- HIGH_VALUE customers spend **3.4x more** than LOW_VALUE — justify premium retention spend here

---

## 👤 Author

Built as part of a portfolio replicating real-world e-commerce analytics at scale across multi-brand retail operations.

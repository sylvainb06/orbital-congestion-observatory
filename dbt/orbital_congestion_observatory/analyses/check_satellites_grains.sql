-- ============================================================
-- CHECK SATELLITES GRAIN
-- ============================================================
-- Goal:
-- Verify that the satellites intermediate model contains
-- exactly one row per NORAD catalog identifier.
--
-- This diagnostic revealed 15,988 rows for 15,985 distinct
-- NORAD IDs, indicating duplicated objects after source joins.
--
-- This observation triggered the investigation of GCAT duplicates
-- and the creation of the gcat_matched CTE.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT norad_cat_id) AS distinct_norad,
    COUNTIF(norad_cat_id IS NULL) AS null_norad

FROM {{ ref('satellites') }};

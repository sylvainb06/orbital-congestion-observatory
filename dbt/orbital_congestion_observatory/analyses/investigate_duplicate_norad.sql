-- ============================================================
-- INVESTIGATE DUPLICATE NORAD IDs
-- ============================================================
-- Goal:
-- Identify NORAD identifiers appearing more than once in the
-- satellites model.
--
-- The investigation identified duplicated NORAD IDs such as:
-- 68635, 68984 and 68488.
--
-- GCAT could contain multiple records associated with the same
-- NORAD identifier, multiplying rows during the JOIN.
--
-- This led to deduplicating GCAT with ROW_NUMBER() and QUALIFY.
-- ============================================================

SELECT
    norad_cat_id,
    COUNT(*) AS row_count

FROM {{ ref('satellites') }}

GROUP BY norad_cat_id

HAVING COUNT(*) > 1

ORDER BY row_count DESC;

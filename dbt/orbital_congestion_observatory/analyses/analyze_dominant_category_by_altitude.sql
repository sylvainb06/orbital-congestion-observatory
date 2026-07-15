-- ============================================================
-- ANALYZE DOMINANT OBJECT CATEGORY BY ALTITUDE
-- ============================================================
-- Goal:
-- Identify the dominant orbital object category in each
-- 50 km altitude band.
--
-- Unlike threshold-based classifications, this analysis does
-- not impose an arbitrary debris percentage.
--
-- The dominant category is directly derived from the largest
-- population count in each altitude band.
--
-- The analysis revealed a structural transition:
--
-- 550 km -> Payload dominant
-- 600 km -> Debris dominant
--
-- This suggests that debris becomes structurally dominant from
-- the 600 km mean-altitude band in our catalogued population.
-- ============================================================

SELECT
    altitude_band_km,
    object_count,
    payload_count,
    debris_count,
    rocket_count,
    component_count,
    debris_share_pct,
    non_payload_share_pct,

    GREATEST(
        payload_count,
        debris_count,
        rocket_count,
        component_count
    ) AS dominant_category_count,

    CASE

        WHEN payload_count = GREATEST(
            payload_count,
            debris_count,
            rocket_count,
            component_count
        ) THEN 'Payload'

        WHEN debris_count = GREATEST(
            payload_count,
            debris_count,
            rocket_count,
            component_count
        ) THEN 'Debris'

        WHEN rocket_count = GREATEST(
            payload_count,
            debris_count,
            rocket_count,
            component_count
        ) THEN 'Rocket'

        WHEN component_count = GREATEST(
            payload_count,
            debris_count,
            rocket_count,
            component_count
        ) THEN 'Component'

        ELSE 'Other'

    END AS dominant_category

FROM {{ ref('orbital_congestion') }}

ORDER BY altitude_band_km;

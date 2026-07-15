-- ============================================================
-- ANALYZE DEBRIS DOMINANCE RANGES
-- ============================================================
-- Goal:
-- Identify continuous altitude ranges where debris is the
-- dominant catalogued object category.
--
-- The previous analysis revealed the first debris-dominated
-- band at 600 km.
--
-- However, debris dominance is not necessarily continuous above
-- this altitude. This analysis detects consecutive 50 km bands
-- sharing the same dominance state.
-- ============================================================

WITH dominance AS (

    SELECT
        altitude_band_km,

        CASE
            WHEN debris_count = GREATEST(
                payload_count,
                debris_count,
                rocket_count,
                component_count
            )
            THEN 1
            ELSE 0
        END AS is_debris_dominated

    FROM {{ ref('orbital_congestion') }}

),

transitions AS (

    SELECT
        *,

        LAG(is_debris_dominated) OVER (
            ORDER BY altitude_band_km
        ) AS previous_state

    FROM dominance

),

dominance_groups AS (

    SELECT
        *,

        SUM(
            CASE
                WHEN previous_state IS NULL
                    OR is_debris_dominated != previous_state
                THEN 1
                ELSE 0
            END
        ) OVER (
            ORDER BY altitude_band_km
        ) AS range_id

    FROM transitions

)

SELECT
    range_id,
    MIN(altitude_band_km) AS start_altitude_km,
    MAX(altitude_band_km) AS end_altitude_km,
    COUNT(*) AS band_count,
    is_debris_dominated

FROM dominance_groups

GROUP BY
    range_id,
    is_debris_dominated

ORDER BY start_altitude_km;

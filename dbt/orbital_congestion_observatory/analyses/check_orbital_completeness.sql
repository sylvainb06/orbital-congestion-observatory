-- ============================================================
-- CHECK ORBITAL DATA COMPLETENESS
-- ============================================================
-- Goal:
-- Verify whether orbital parameters are available across object
-- categories.
--
-- We initially suspected that debris might disappear from the
-- congestion analysis because their perigee or apogee values
-- were missing.
--
-- Results showed that orbital parameters were nearly complete
-- for all major categories.
--
-- Missing orbital data was therefore NOT the cause of the
-- payload-dominated initial congestion results.
-- ============================================================

SELECT
    object_category,
    COUNT(*) AS total_objects,

    COUNTIF(best_available_perigee_km IS NOT NULL)
        AS with_perigee,

    COUNTIF(best_available_apogee_km IS NOT NULL)
        AS with_apogee,

    COUNTIF(
        best_available_perigee_km IS NOT NULL
        AND best_available_apogee_km IS NOT NULL
    ) AS with_complete_orbit

FROM {{ ref('orbital_objects') }}

GROUP BY object_category

ORDER BY total_objects DESC;

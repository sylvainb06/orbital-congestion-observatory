-- ============================================================
-- CHECK OBJECT CATEGORY DISTRIBUTION
-- ============================================================
-- Goal:
-- Understand the composition of the orbital object population.
--
-- Initial analysis based mainly on CelesTrak produced a population
-- overwhelmingly dominated by payloads and almost no debris.
--
-- GCAT revealed a much broader orbital population including:
-- debris, payloads, components and rocket bodies.
--
-- This observation led us to use GCAT as the reference population
-- for orbital congestion analysis.
-- ============================================================

SELECT
    object_category,
    COUNT(*) AS object_count

FROM {{ ref('orbital_objects') }}

GROUP BY object_category

ORDER BY object_count DESC;

-- ============================================================
-- EXPLORE CONGESTION COMPOSITION
-- ============================================================
-- Goal:
-- Compare congestion volume with the composition of orbital
-- populations.
--
-- A highly populated altitude band is not necessarily dominated
-- by debris.
--
-- The analysis revealed two distinct congestion profiles:
--
-- 450-500 km:
-- High object concentration, mainly payloads.
--
-- 700-900 km:
-- Lower absolute population but strongly debris-dominated.
--
-- This distinction motivated the congestion profile analysis.
-- ============================================================

SELECT
    altitude_band_km,
    object_count,
    payload_count,
    debris_count,
    rocket_count,
    component_count,
    debris_share_pct,
    non_payload_share_pct

FROM {{ ref('orbital_congestion') }}

ORDER BY debris_share_pct DESC;

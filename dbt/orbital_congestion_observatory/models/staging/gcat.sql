-- =============================================================== --
-- STAGING GCAT — McDowell catalog (satcat)
-- 1 row = 1 space object (unique key: jcat)
-- norad_id: STRING; 'NNA' kept as-is = not catalogued by the US Space Force
-- Excluded: '#Updated' header row + S69942 placeholder (no launch date)
-- =============================================================== --

SELECT
  -- IDENTIFIERS
  JCAT AS jcat
  ,TRIM(Satcat) AS norad_id
  ,Piece AS cospar_id
  ,Name AS name
  ,Launch_Tag AS launch_tag

  -- CLASSIFICATION
  ,Type AS type_code
  ,CASE
    WHEN Type LIKE 'P%' THEN 'Payload'
    WHEN Type LIKE 'R%' THEN 'Rocket'
    WHEN Type LIKE 'C%' THEN 'Component'
    WHEN Type LIKE 'D%' THEN 'Debris'
    ELSE 'Other'
  END AS category

  -- ACTORS
  ,Owner AS owner
  ,State AS state
  ,Manufacturer AS manufacturer

  -- LIFECYCLE ('?' uncertainty indicator remove from status)
  ,REGEXP_REPLACE(TRIM(Status), r'\?$', '') AS status
  ,Parent AS parent
  ,SAFE.PARSE_DATE('%Y %b %e',
      REGEXP_REPLACE(
        REGEXP_EXTRACT(TRIM(LDate), r'^\d{4} [A-Za-z]{3} +\d{1,2}')
        , r' +', ' ')) AS launch_date
  ,SAFE_CAST(REGEXP_EXTRACT(TRIM(LDate), r'\d{4}') AS INT64) AS launch_year
  ,SAFE.PARSE_DATE('%Y %b %e',
      REGEXP_REPLACE(
        REGEXP_EXTRACT(TRIM(SDate), r'^\d{4} [A-Za-z]{3} +\d{1,2}')
        , r' +', ' ')) AS separation_date
  ,SAFE_CAST(REGEXP_EXTRACT(TRIM(SDate), r'\d{4}') AS INT64) AS separation_year
  ,SAFE.PARSE_DATE('%Y %b %e',
      REGEXP_REPLACE(
        REGEXP_EXTRACT(TRIM(DDate), r'^\d{4} [A-Za-z]{3} +\d{1,2}')
        , r' +', ' ')) AS decay_date
  ,SAFE_CAST(REGEXP_EXTRACT(TRIM(DDate), r'\d{4}') AS INT64) AS decay_year

  -- ORBITS
  ,OpOrbit AS orbit_class
  ,SAFE_CAST(Perigee AS FLOAT64) AS perigee_km
  ,SAFE_CAST(Apogee AS FLOAT64) AS apogee_km
  ,SAFE_CAST(Inc AS FLOAT64) AS inclination_deg

  -- PHYSICAL CHARACTERISTICS
  ,SAFE_CAST(Mass AS FLOAT64) AS mass_kg
  ,SAFE_CAST(DryMass AS FLOAT64) AS dry_mass_kg
  ,SAFE_CAST(TotMass AS FLOAT64) AS total_mass_kg
  ,SAFE_CAST(Length AS FLOAT64) AS length_m
  ,SAFE_CAST(Diameter AS FLOAT64) AS diameter_m
  ,SAFE_CAST(Span AS FLOAT64) AS span_m
  ,Bus AS bus

FROM {{ source('space_raw', 'GCAT') }}
WHERE REGEXP_EXTRACT(TRIM(LDate), r'\d{4}') IS NOT NULL

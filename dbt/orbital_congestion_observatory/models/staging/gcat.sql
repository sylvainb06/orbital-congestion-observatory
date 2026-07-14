SELECT
  JCAT AS jcat,
  SAFE_CAST(
    NULLIF(LOWER(TRIM(Satcat)), 'no_assigned')
    AS INT64
  ) AS norad_cat_id,
  Name AS name,
  Type AS type_code,

  CASE
    WHEN Type LIKE 'P%' THEN 'Payload'
    WHEN Type LIKE 'R%' THEN 'Rocket'
    WHEN Type LIKE 'C%' THEN 'Component'
    WHEN Type LIKE 'D%' THEN 'Debris'
    ELSE 'Autre'
  END AS categorie,

  Owner AS owner,
  Manufacturer AS manufacturer,
  State AS state,
  Status AS status,
  OpOrbit AS orbit_class,

  SAFE_CAST(REGEXP_EXTRACT(TRIM(LDate), r'\d{4}') AS INT64) AS launch_year,
  SAFE_CAST(REGEXP_EXTRACT(TRIM(DDate), r'\d{4}') AS INT64) AS decay_year,

  SAFE_CAST(Perigee AS FLOAT64) AS perigee_km,
  SAFE_CAST(Apogee AS FLOAT64) AS apogee_km,
  SAFE_CAST(Inc AS FLOAT64) AS inclination_deg,
  SAFE_CAST(Mass AS FLOAT64) AS mass_kg,
  SAFE_CAST(DryMass AS FLOAT64) AS dry_mass_kg,
  SAFE_CAST(TotMass AS FLOAT64) AS total_mass_kg

FROM {{ source('space_raw', 'GCAT') }}

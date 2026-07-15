-- =============================================================== --
-- STAGING UCS — UCS Satellite Database (frozen snapshot: 2023-05-01)
-- 1 row = 1 operational satellite as of May 2023 (no debris, no rockets)
-- norad_id: STRING to match GCAT, 9 known duplicates
-- dry_mass_kg / power_watts: values with ranges or notes ('1,500-1,900', '2,800 (EOL)') are set to NULL by SAFE_CAST — columns kept for reference only
-- Source discontinued: no update will ever exist beyond 2023-05-01
-- =============================================================== --

SELECT
  -- IDENTIFIERS
  SAFE_CAST(norad_number AS STRING) AS norad_id
  ,cospar_number AS cospar_id
  ,current_official_name_of_satellite AS name

  -- ACTORS
  ,contractor
  ,country_of_contractor AS contractor_country
  ,country_org_of_un_registry AS registry_country
  ,operator_owner AS operator
  ,country_of_operator_owner AS operator_country
  ,users AS users_sector

  -- USAGES
  ,purpose
  ,detailed_purpose AS purpose_detail

  -- ORBITS
  ,UPPER(TRIM(class_of_orbit)) AS orbit_class
  ,type_of_orbit AS orbit_type

  ,SAFE_CAST(longitude_of_geo_degrees AS FLOAT64) AS geo_longitude_deg
  ,SAFE_CAST(perigee_km AS FLOAT64) AS perigee_km
  ,SAFE_CAST(apogee_km AS FLOAT64) AS apogee_km
  ,SAFE_CAST(eccentricity AS FLOAT64) AS eccentricity
  ,SAFE_CAST(inclination_degrees AS FLOAT64) AS inclination_deg
  ,SAFE_CAST(period_minutes AS FLOAT64) AS period_min

  -- PHYSICAL CHARACTERISTICS
  ,SAFE_CAST(launch_mass_kg AS FLOAT64) AS launch_mass_kg
  ,SAFE_CAST(dry_mass_kg AS FLOAT64) AS dry_mass_kg
  ,SAFE_CAST(power_watts AS FLOAT64) AS power_watts
  ,SAFE_CAST(expected_lifetime_yrs AS FLOAT64) AS expected_lifetime_yrs

  -- LAUNCH
  ,DATE(SAFE_CAST(date_of_launch AS DATETIME)) AS launch_date
  ,launch_site
  ,launch_vehicle

FROM {{ source('space_raw', 'UCS') }}

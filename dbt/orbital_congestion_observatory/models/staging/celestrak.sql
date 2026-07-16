WITH source AS (

  SELECT
    object_name,
    object_id,
    epoch,
    mean_motion,
    eccentricity,
    inclination,
    ra_of_asc_node,
    arg_of_pericenter,
    mean_anomaly,
    ephemeris_type,
    classification_type,
    SAFE_CAST(norad_cat_id AS STRING) AS norad_cat_id,
    element_set_no,
    rev_at_epoch,
    bstar,
    mean_motion_dot,
    mean_motion_ddot

  FROM {{ source('space_raw', 'celestrak') }}

),

orbital_period AS (

  SELECT
    *,
    SAFE_DIVIDE(1440, mean_motion) AS orbital_period_min
  FROM source

),

semi_major_axis AS (

  SELECT
    *,
    POW(
      398600.4418
      * POW(orbital_period_min * 60, 2)
      / (4 * POW(ACOS(-1), 2)),
      1.0 / 3.0
    ) AS semi_major_axis_km

  FROM orbital_period

),

orbital_altitudes AS (

  SELECT
    *,
    semi_major_axis_km * (1 - eccentricity) - 6378.137
      AS perigee_altitude_km,

    semi_major_axis_km * (1 + eccentricity) - 6378.137
      AS apogee_altitude_km

  FROM semi_major_axis

),

orbital_classification AS (

  SELECT
    *,

    CASE

      WHEN apogee_altitude_km < 2000
        THEN 'LEO_CONTAINED'

      WHEN perigee_altitude_km < 2000
        AND apogee_altitude_km >= 2000
        THEN 'LEO_CROSSING'

      WHEN orbital_period_min BETWEEN 1400 AND 1470
        AND inclination < 1
        AND eccentricity < 0.01
        THEN 'GEO_STATIONARY'

      WHEN orbital_period_min BETWEEN 1400 AND 1470
        THEN 'GEO_SYNCHRONOUS'

      WHEN perigee_altitude_km >= 2000
        AND eccentricity >= 0.1
        THEN 'HEO'

      WHEN perigee_altitude_km >= 2000
        AND apogee_altitude_km < 35000
        THEN 'MEO'

      ELSE 'OTHER_HIGH_ORBIT'

    END AS orbital_zone

  FROM orbital_altitudes

)

SELECT *
FROM orbital_classification

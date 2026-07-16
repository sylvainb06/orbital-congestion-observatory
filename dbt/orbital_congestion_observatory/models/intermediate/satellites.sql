WITH celestrak AS (

    SELECT *
    FROM {{ ref('celestrak') }}

),

gcat AS (

    SELECT *
    FROM {{ ref('gcat') }}

),

ucs AS (

    SELECT *
    FROM {{ ref('ucs') }}

),

gcat_matched AS (

    SELECT *
    FROM gcat

    WHERE norad_id IS NOT NULL

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY norad_id
        ORDER BY jcat
    ) = 1

),

ucs_matched AS (

    SELECT DISTINCT
        u.*

    FROM ucs AS u

    INNER JOIN celestrak AS c
        ON u.norad_id = c.norad_cat_id
        AND u.cospar_id = c.object_id

),

satellites AS (

    SELECT

        -- IDENTIFIERS
        c.norad_cat_id,
        c.object_id AS cospar_id,
        g.jcat,

        -- OBJECT
        c.object_name,
        g.name AS gcat_object_name,
        g.categorie AS object_category,
        g.type_code,
        g.status,

        -- OWNERSHIP / OPERATIONS
        g.owner,
        g.manufacturer,
        g.state,

        u.operator,
        u.operator_country,
        u.contractor,
        u.contractor_country,
        u.registry_country,
        u.users_sector,

        -- PURPOSE
        u.purpose,
        u.purpose_detail,

        -- ORBIT CLASSIFICATION
        c.orbital_zone,
        g.orbit_class AS gcat_orbit_class,
        u.orbit_class AS ucs_orbit_class,
        u.orbit_type,

        -- PERIGEE BY SOURCE
        c.perigee_altitude_km AS celestrak_perigee_km,
        u.perigee_km AS ucs_perigee_km,
        g.perigee_km AS gcat_perigee_km,

        -- APOGEE BY SOURCE
        c.apogee_altitude_km AS celestrak_apogee_km,
        u.apogee_km AS ucs_apogee_km,
        g.apogee_km AS gcat_apogee_km,

        -- BEST AVAILABLE ORBITAL VALUES
        COALESCE(
            c.perigee_altitude_km,
            u.perigee_km,
            g.perigee_km
        ) AS best_available_perigee_km,

        COALESCE(
            c.apogee_altitude_km,
            u.apogee_km,
            g.apogee_km
        ) AS best_available_apogee_km,

        COALESCE(
            c.inclination,
            u.inclination_deg,
            g.inclination_deg
        ) AS inclination_deg,

        -- CELESTRAK ORBITAL PARAMETERS
        c.eccentricity,
        c.orbital_period_min AS period_min,
        c.semi_major_axis_km,
        u.geo_longitude_deg,

        -- PHYSICAL CHARACTERISTICS
        COALESCE(
            u.launch_mass_kg,
            g.mass_kg
        ) AS mass_kg,

        COALESCE(
            u.dry_mass_kg,
            g.dry_mass_kg
        ) AS dry_mass_kg,

        g.total_mass_kg,
        u.power_watts,
        u.expected_lifetime_yrs,

        -- LAUNCH / DECAY
        g.launch_year,
        g.decay_year,
        u.launch_date,
        u.launch_site,
        u.launch_vehicle

    FROM celestrak AS c

    LEFT JOIN gcat_matched AS g
        ON c.norad_cat_id = g.norad_id

    LEFT JOIN ucs_matched AS u
        ON c.norad_cat_id = u.norad_id
        AND c.object_id = u.cospar_id

)

SELECT *
FROM satellites

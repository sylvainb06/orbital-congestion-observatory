WITH gcat AS (

    SELECT *
    FROM {{ ref('gcat') }}

),

celestrak AS (

    SELECT *
    FROM {{ ref('celestrak') }}

),

orgs AS (

    SELECT *
    FROM {{ ref('orgs') }}

),

orbital_objects AS (

    SELECT

        -- IDENTIFIERS
        g.jcat,
        g.norad_id AS norad_cat_id,
        c.object_id AS cospar_id,

        -- OBJECT
        COALESCE(
            c.object_name,
            g.name
        ) AS object_name,

        g.categorie AS object_category,
        g.type_code,
        g.status,

        -- OWNERSHIP
        g.owner AS owner_code,
        o.org_name AS owner_name,
        o.state_code AS owner_state_code,
        o.org_class AS owner_class,

        g.manufacturer,
        g.state AS owner_country_gcat,

        -- ORBIT CLASSIFICATION
        c.orbital_zone,
        g.orbit_class AS gcat_orbit_class,

        -- ORBITAL VALUES BY SOURCE
        c.perigee_altitude_km AS celestrak_perigee_km,
        g.perigee_km AS gcat_perigee_km,

        c.apogee_altitude_km AS celestrak_apogee_km,
        g.apogee_km AS gcat_apogee_km,

        -- BEST AVAILABLE ORBITAL VALUES
        COALESCE(
            c.perigee_altitude_km,
            g.perigee_km
        ) AS best_available_perigee_km,

        COALESCE(
            c.apogee_altitude_km,
            g.apogee_km
        ) AS best_available_apogee_km,

        COALESCE(
            c.inclination,
            g.inclination_deg
        ) AS inclination_deg,

        -- CELESTRAK ORBITAL PARAMETERS
        c.eccentricity,
        c.orbital_period_min AS period_min,
        c.semi_major_axis_km,

        -- PHYSICAL CHARACTERISTICS
        g.mass_kg,
        g.dry_mass_kg,
        g.total_mass_kg,

        -- LAUNCH / DECAY
        g.launch_year,
        g.decay_year

    FROM gcat AS g

    LEFT JOIN celestrak AS c
        ON g.norad_id = c.norad_cat_id

    LEFT JOIN orgs AS o
    ON g.owner = o.org_code

)

SELECT *
FROM orbital_objects

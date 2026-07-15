WITH congestion AS (

    SELECT *
    FROM {{ ref('orbital_congestion') }}

),

dominant_categories AS (

    SELECT
        altitude_band_km,
        payload_count,
        debris_count,
        rocket_count,
        component_count,

        CASE
            WHEN payload_count = GREATEST(
                payload_count,
                debris_count,
                rocket_count,
                component_count
            ) THEN 'Payload'

            WHEN debris_count = GREATEST(
                payload_count,
                debris_count,
                rocket_count,
                component_count
            ) THEN 'Debris'

            WHEN rocket_count = GREATEST(
                payload_count,
                debris_count,
                rocket_count,
                component_count
            ) THEN 'Rocket'

            WHEN component_count = GREATEST(
                payload_count,
                debris_count,
                rocket_count,
                component_count
            ) THEN 'Component'

            ELSE 'Other'
        END AS dominant_category

    FROM congestion

),

debris_bands AS (

    SELECT *
    FROM dominant_categories

    WHERE dominant_category = 'Debris'

)

SELECT
    MIN(altitude_band_km) AS first_debris_dominated_band_km

FROM debris_bands

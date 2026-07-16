WITH payloads AS (

    SELECT
        owner_code,
        owner_name,
        owner_class,
        owner_state_code,
        owner_country_gcat,
        launch_year,

        SAFE_CAST(
            FLOOR(
                (
                    best_available_perigee_km
                    + best_available_apogee_km
                ) / 2 / 50
            ) * 50
            AS INT64
        ) AS altitude_band_km

    FROM {{ ref('orbital_objects') }}

    WHERE object_category = 'Payload'

),

owners_by_band AS (

    SELECT
        altitude_band_km,
        owner_code,
        owner_name,
        owner_class,
        owner_state_code,
        COUNT(*) AS payload_count,
        MIN(launch_year) AS first_launch_year,
        MAX(launch_year) AS latest_launch_year

    FROM payloads

    WHERE altitude_band_km IN (
        1150,
        1200,
        1400,
        1450
    )

    GROUP BY
        altitude_band_km,
        owner_code,
        owner_name,
        owner_class,
        owner_state_code,
        owner_country_gcat

)

SELECT *

FROM owners_by_band

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY altitude_band_km
    ORDER BY payload_count DESC
) <= 5

ORDER BY
    altitude_band_km,
    payload_count DESC;

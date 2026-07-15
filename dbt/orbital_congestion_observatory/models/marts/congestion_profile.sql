WITH congestion AS (

    SELECT *
    FROM {{ ref('orbital_congestion') }}

),

profiles AS (

    SELECT
        *,

        CASE

          WHEN object_count >= 5000
              AND debris_share_pct < 50
              THEN 'HIGH_OPERATIONAL_TRAFFIC'

          WHEN debris_share_pct >= 80
              THEN 'DEBRIS_DOMINATED'

          WHEN non_payload_share_pct >= 80
              THEN 'NON_PAYLOAD_DOMINATED'

          WHEN debris_share_pct >= 50
              THEN 'MIXED_HIGH_DEBRIS'

          ELSE 'MIXED_OPERATIONAL'

        END AS congestion_profile

    FROM congestion

)

SELECT *
FROM profiles

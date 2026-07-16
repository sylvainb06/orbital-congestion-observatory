SELECT
  `#Code` AS org_code,
  COALESCE(
    NULLIF(ShortEName, '-'),
    NULLIF(ShortName, '-'),
    `#Code`
  ) AS org_name,
  StateCode AS state_code,
  Class AS org_class
FROM {{ source('space_raw', 'ORGS') }}
WHERE NOT STARTS_WITH(`#Code`, '#')

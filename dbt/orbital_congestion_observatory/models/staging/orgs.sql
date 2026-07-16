-- =============================================================== --
-- STAGING ORGS — McDowell organizations dictionary
-- 1 row = 1 organization code (states included; unique key: org_code)
-- org_class: A=academic, B=business, C=civil gov, D=defense
-- Excluded: '#Updated' header row
-- =============================================================== --

SELECT
  `#Code` AS org_code,
  COALESCE(
    NULLIF(ShortEName, '-'),
    NULLIF(ShortName, '-'),
    `#Code`) AS org_name,
  StateCode AS state_code,
  Class AS org_class
FROM {{ source('space_raw', 'ORGS') }}
WHERE NOT STARTS_WITH(`#Code`, '#')

-- =============================================================== --
-- INTERMEDIATE — GCAT objects enriched with readable organizations
-- ORGS joined twice: owner codes -> name/class/country, state -> country name
-- INNER JOIN on owner drops uncertain owners ('?' codes, ~88 rows, documented)
-- LEFT JOIN on state: no row loss if a state code is missing from ORGS
-- =============================================================== --

SELECT
  g.norad_id
  ,g.cospar_id
  ,g.name
  ,g.category
  ,g.status
  ,g.owner
  ,o.org_name AS owner_name
  ,o.org_class AS owner_class
  ,o.state_code AS owner_country_code
  ,g.state
  ,s.org_name AS state_name
  ,g.orbit_class
  ,g.launch_date
  ,g.launch_year
  ,g.decay_year
FROM {{ ref('gcat') }} AS g
INNER JOIN {{ ref('orgs') }} AS o
  ON SPLIT(g.owner, '/')[OFFSET(0)] = o.org_code
LEFT JOIN {{ ref('orgs') }} AS s
  ON g.state = s.org_code

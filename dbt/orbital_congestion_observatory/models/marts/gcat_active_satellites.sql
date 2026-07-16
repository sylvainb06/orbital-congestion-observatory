-- =============================================================== --
-- INTERMEDIATE — Active satellites (payloads in orbit, 2026)
-- Team definition of "active": category = Payload AND status O/OX
-- One row = 1 satellite; Looker aggregates on top of this view
-- =============================================================== --

SELECT
    j.*
  , CASE j.owner_class
        WHEN 'B' THEN 'Business/commercial'
        WHEN 'C' THEN 'Civil government'
        WHEN 'D' THEN 'Defense / Military / Intelligence'
        WHEN 'A' THEN 'Academic / Non-profit'
        ELSE j.owner_class
    END                                                        AS owner_sector
  , STARTS_WITH(j.state, 'I-')                                 AS is_international
  FROM {{ ref('join_gcat_orgs') }} AS j
  WHERE j.category = 'Payload'
    AND j.status IN ('O', 'OX')

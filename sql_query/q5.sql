-- SELECT
--   FLOOR((
--     CASE
--       WHEN MET.pt < 0 THEN -1
--       WHEN MET.pt > 2000 THEN 2001
--       ELSE MET.pt
--     END) / 20) * 20 + 10 AS x,
--   COUNT(*) AS y
-- FROM {dataset_path}
-- WHERE ARRAY_LENGTH(Muon.list) >= 2 AND
--   (SELECT COUNT(*) AS mass
--    FROM UNNEST(Muon.list) m1 WITH OFFSET i
--    CROSS JOIN UNNEST(Muon.list) m2 WITH OFFSET j
--    WHERE
--      m1.element.charge <> m2.element.charge AND i < j AND
--      SQRT(2*m1.element.pt*m2.element.pt*(COSH(m1.element.eta-m2.element.eta)-COS(m1.element.phi-m2.element.phi))) BETWEEN 60 AND 120) > 0
-- GROUP BY x
-- ORDER BY x;

-- -- athena
-- WITH temp AS (
--   SELECT event, MET.pt, COUNT(*)
--   FROM `run_res.run_res`
--   CROSS JOIN UNNEST(Muon.list) m1 WITH OFFSET idx1
--   CROSS JOIN UNNEST(Muon.list) m2 WITH OFFSET idx2
--   WHERE
--     ARRAY_LENGTH(Muon.list) > 1 AND
--     idx1 < idx2
--     AND m1.element.charge <> m2.element.charge AND
--     SQRT(2 * m1.element.pt * m2.element.pt * (COSH(m1.element.eta - m2.element.eta) - COS(m1.element.phi - m2.element.phi))) BETWEEN 60 AND 120
--   GROUP BY event, MET.pt
--   HAVING COUNT(*) > 0
-- )
-- SELECT
--   FLOOR((
--     CASE
--       WHEN pt < 0 THEN -1
--       WHEN pt > 2000 THEN 2001
--       ELSE pt
--     END) / 20) * 20 + 10 AS x,
--   COUNT(*) AS y
-- FROM temp
-- GROUP BY x
-- ORDER BY x;

-- -- malloy --

-- WITH __stage0 AS (
--   SELECT 
--      cross_join_sql.MET.pt as met_pt,
--      cross_join_sql.event as event,
--      cross_join_sql.idx1 as idx1,
--      cross_join_sql.idx2 as idx2,
--      cross_join_sql.m1.element.charge as m1_c,
--      cross_join_sql.m2.element.charge as m2_c,
--      cross_join_sql.m1.element.pt as m1_pt,
--      cross_join_sql.m2.element.pt as m2_pt,
--      cross_join_sql.m1.element.phi as m1_phi,
--      cross_join_sql.m2.element.phi as m2_phi,
--      cross_join_sql.m1.element.eta as m1_eta,
--      cross_join_sql.m2.element.eta as m2_eta
--   FROM (
--           SELECT
--               Muon, m1, m2, MET, event, idx1, idx2
--           FROM `hep2.hep`
--           CROSS JOIN UNNEST(Muon.list) m1 WITH OFFSET idx1
--           CROSS JOIN UNNEST(Muon.list) m2 WITH OFFSET idx2    
--           ) as cross_join_sql
--   GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
--   HAVING ((((COUNT( 1)>1) and (cross_join_sql.idx1<cross_join_sql.idx2))and (COALESCE(NOT((cross_join_sql.m1.element.charge)=(cross_join_sql.m2.element.charge)),FALSE)))and (((sqrt(((2*(cross_join_sql.m1.element.pt))*(cross_join_sql.m2.element.pt))*(((cosh((cross_join_sql.m1.element.eta)-(cross_join_sql.m2.element.eta)))-(cos((cross_join_sql.m1.element.phi)-(cross_join_sql.m2.element.phi)))))))>60)and((sqrt(((2*(cross_join_sql.m1.element.pt))*(cross_join_sql.m2.element.pt))*(((cosh((cross_join_sql.m1.element.eta)-(cross_join_sql.m2.element.eta)))-(cos((cross_join_sql.m1.element.phi)-(cross_join_sql.m2.element.phi)))))))<120)))
--   AND (COUNT( 1)>0)
--   ORDER BY 1 asc
-- )
-- SELECT 
--    ((floor((CASE WHEN base.met_pt<0 THEN -1 WHEN base.met_pt>2000 THEN 2001 ELSE base.met_pt END)/20))*20)+10 as x,
--    COUNT( 1) as y
-- FROM __stage0 as base
-- GROUP BY 1
-- ORDER BY 1 ASC

--bigquery
WITH temp AS (
  SELECT event, MET.pt, COUNT(*)
  FROM `hep2.hep`
  CROSS JOIN UNNEST(Muon.list) m1 WITH OFFSET idx1
  CROSS JOIN UNNEST(Muon.list) m2 WITH OFFSET idx2
  WHERE
    ARRAY_LENGTH(Muon.list) > 1 AND
    idx1 < idx2
    AND m1.element.charge <> m2.element.charge AND
    SQRT(2 * m1.element.pt * m2.element.pt * (COSH(m1.element.eta - m2.element.eta) - COS(m1.element.phi - m2.element.phi))) BETWEEN 60 AND 120
  GROUP BY event, MET.pt
  HAVING COUNT(*) > 0
)
SELECT
  FLOOR((
    CASE
      WHEN pt < 0 THEN -1
      WHEN pt > 2000 THEN 2001
      ELSE pt
    END) / 20) * 20 + 10 AS x,
  COUNT(*) AS y
FROM temp
GROUP BY x
ORDER BY x;
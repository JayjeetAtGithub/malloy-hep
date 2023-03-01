-- WITH __stage0 AS (
--   SELECT
--      cross_join_sql."MET", 
--      COUNT(DISTINCT cross_join_sql."__distinct_key") as "c"
--   FROM (SELECT GEN_RANDOM_UUID() as __distinct_key, * FROM (
--           SELECT
--               unnest(Jet) as J,
--               Jet,
--               MET,
--           FROM read_parquet('/mnt/data/*.parquet')
--       ) as x) as cross_join_sql
--   LEFT JOIN (select UNNEST(generate_series(1,
--           100000, --
--           -- (SELECT genres_length FROM movies limit 1),
--           1)) as __row_id) as Jet_0 ON  Jet_0.__row_id <= array_length(cross_join_sql."Jet")
--   WHERE cross_join_sql.J."pt">40
--   GROUP BY cross_join_sql."MET"
--   ORDER BY 1 desc NULLS LAST
-- ),
-- __stage1 AS (
-- SELECT 
--    base."MET" as "MET",
-- FROM __stage0 as base
-- WHERE base."c">1
-- ),
-- __stage2 AS (
--   SELECT
--      ((floor((CASE WHEN hep.MET."pt"<0 THEN -1 WHEN hep.MET."pt">2000 THEN 2001 ELSE hep.MET."pt" END)*1.0/20))*20)+10 as "x",
--      COUNT( 1) as "y"
--   FROM __stage1 as hep
--   GROUP BY 1
--   ORDER BY 1 ASC NULLS LAST
-- )
-- SELECT
--    base."x" as "x",
--    base."y" as "y"
-- FROM __stage2 as base
-- this does not work for replicated files, group by cannot distinguish between same rows from different files


-- WITH __stage0 AS (
--   SELECT
--      ((floor((CASE WHEN hep.MET."pt"<0 THEN -1 WHEN hep.MET."pt">2000 THEN 2001 ELSE hep.MET."pt" END)*1.0/20))*20)+10 as "x",
--      COUNT( 1) as "y"
--   FROM '/mnt/data/*.parquet' as hep
--   WHERE (
--    (SELECT count(*) FROM UNNEST(hep.Jet) WHERE Jet.pt>40)>1
--   )
--   GROUP BY 1
--   ORDER BY 1 ASC NULLS LAST
-- )
-- SELECT
--    base."x" as "x",
--    base."y" as "y"
-- FROM __stage0 as base
-- this works, just a copy of Q1 with the unnest thing, but no perf improvement, obviously :(.
WITH __stage0 AS (
  SELECT 
     hep."uid" as "uid",
     ANY_VALUE(hep."MET") as "MET",
  FROM (SELECT gen_random_uuid() uid, * FROM '/mnt/data/*.parquet') as hep
  LEFT JOIN (select UNNEST(generate_series(1,
          100000, --
          -- (SELECT genres_length FROM movies limit 1),
          1)) as __row_id) as Jet_0 ON  Jet_0.__row_id <= array_length(hep."Jet")
  GROUP BY 1
  HAVING (COUNT( CASE WHEN hep.Jet[Jet_0.__row_id]."pt">40 THEN 1 END)>1)
  ORDER BY 1 asc NULLS LAST
),
__stage1 AS (
  SELECT
     ((floor((CASE WHEN hep.MET."pt"<0 THEN -1 WHEN hep.MET."pt">2000 THEN 2001 ELSE hep.MET."pt" END)*1.0/20))*20)+10 as "x",
     COUNT( 1) as "y"
  FROM __stage0 as hep
  GROUP BY 1
  ORDER BY 1 ASC NULLS LAST
)
SELECT
   base."x" as "x",
   base."y" as "y"
FROM __stage1 as base
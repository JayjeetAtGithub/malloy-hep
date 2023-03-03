WITH __stage0 AS (
  SELECT
     ((floor((CASE WHEN hep.MET."pt"<0 THEN -1 WHEN hep.MET."pt">2000 THEN 2001 ELSE hep.MET."pt" END)*1.0/20))*20)+10 as "x",
     COUNT( 1) as "y"
  FROM '/mnt/data/dataset/*.parquet' as hep
  GROUP BY 1
  ORDER BY 1 ASC NULLS LAST
)
SELECT
   base."x" as "x",
   base."y" as "y"
FROM __stage0 as base
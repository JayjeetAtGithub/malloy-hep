WITH __stage0 AS (
  SELECT 
     ((floor((((CASE WHEN cross_join_sql.J."pt"<15 THEN 14.99 WHEN cross_join_sql.J."pt">60 THEN 60.01 ELSE cross_join_sql.J."pt" END))-0.15)*1.0/0.45))*0.45)+0.375 as "x",
     COUNT( 1) as "y"
  FROM (
          SELECT
              unnest(Jet) as J,
              MET
          FROM '/mnt/data/*.parquet'
      ) as cross_join_sql
  GROUP BY 1
  ORDER BY 1 ASC NULLS LAST
)
SELECT 
   base."x" as "x",
   base."y" as "y"
FROM __stage0 as base
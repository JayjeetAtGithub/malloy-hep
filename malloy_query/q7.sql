WITH __stage0 AS (
  SELECT 
     cross_join_sql."event" as "event",
     COALESCE(SUM(cross_join_sql.j."pt"),0) as "pt_sum"
  FROM (
          SELECT j, event
          FROM (SELECT
                  event, Electron, Muon, unnest(Jet) as j
              FROM read_parquet('../hep.parquet')
          )
          WHERE 
              array_length(array_filter(
                  Electron,
                  x -> ((x.pt > 10) and (sqrt((j.eta - x.eta) * (j.eta - x.eta) + power((j.phi - x.phi + pi()) % (2 * pi()) - pi(), 2)) < 0.4)))) = 0
          AND array_length(array_filter(
                  Muon,
                  x -> ((x.pt > 10) and (sqrt((j.eta - x.eta) * (j.eta - x.eta) + power((j.phi - x.phi + pi()) % (2 * pi()) - pi(), 2)) < 0.4)))) = 0
          ) as cross_join_sql
  WHERE cross_join_sql.j."pt">30
  GROUP BY 1
  ORDER BY 2 desc NULLS LAST
)
SELECT 
   ((floor((CASE WHEN base."pt_sum"<15 THEN 14.9 WHEN base."pt_sum">200 THEN 200.1 ELSE base."pt_sum"-0.2 END)*1.0/1.85))*1.85)+1.125 as "x",
   COUNT( 1) as "y"
FROM __stage0 as base
GROUP BY 1
ORDER BY 1 ASC NULLS LAST

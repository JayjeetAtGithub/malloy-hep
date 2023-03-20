WITH __stage0 AS (
  SELECT 
     cross_join_sql.MET.pt as met_pt,
     cross_join_sql.event as event
  FROM (
          SELECT
              Muon, m1, m2, MET, event, idx1, idx2, array_length(Muon.list) as Mlen
          FROM `hep2.hep`
          CROSS JOIN UNNEST(Muon.list) m1 WITH OFFSET idx1
          CROSS JOIN UNNEST(Muon.list) m2 WITH OFFSET idx2    
          ) as cross_join_sql
  WHERE (((cross_join_sql.Mlen>1) and (cross_join_sql.idx1<cross_join_sql.idx2))and (COALESCE(NOT((cross_join_sql.m1.element.charge)=(cross_join_sql.m2.element.charge)),FALSE)))and (((sqrt(((2*(cross_join_sql.m1.element.pt))*(cross_join_sql.m2.element.pt))*(((cosh((cross_join_sql.m1.element.eta)-(cross_join_sql.m2.element.eta)))-(cos((cross_join_sql.m1.element.phi)-(cross_join_sql.m2.element.phi)))))))>=60)and((sqrt(((2*(cross_join_sql.m1.element.pt))*(cross_join_sql.m2.element.pt))*(((cosh((cross_join_sql.m1.element.eta)-(cross_join_sql.m2.element.eta)))-(cos((cross_join_sql.m1.element.phi)-(cross_join_sql.m2.element.phi)))))))<=120))
  GROUP BY 1,2
  HAVING COUNT( 1)>0
  ORDER BY 1 asc
)
SELECT 
   ((floor((CASE WHEN base.met_pt<0 THEN -1 WHEN base.met_pt>2000 THEN 2001 ELSE base.met_pt END)/20))*20)+10 as x,
   COUNT( 1) as y
FROM __stage0 as base
GROUP BY 1
ORDER BY 1 ASC
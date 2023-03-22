--bigquery--
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
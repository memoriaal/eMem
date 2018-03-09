CREATE OR REPLACE VIEW aruanne_muutused_peale_publitseerimist_02_13 AS
SELECT o.emi_id, o.perenimi, o.eesnimi, o.isanimi, o.sünd, o.surm, o.kirjed, p.emi_id AS Pemi_id, p.perenimi AS Pperenimi, p.eesnimi AS Peesnimi, p.isanimi AS Pisanimi, p.sünd AS Psünd, p.surm AS Psurm, p.kirjed AS Pkirjed
FROM ohvrite_nimekiri_2018_02_13 o
JOIN v_publish p
ON o.emi_id = p.emi_id
WHERE o.perenimi != p.perenimi
   or o.eesnimi != p.eesnimi
   or o.isanimi != p.isanimi
   or o.sünd != p.sünd
   or o.surm != p.surm

UNION

SELECT emi_id, perenimi, eesnimi, isanimi, sünd, surm, kirjed, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM ohvrite_nimekiri_2018_02_13
WHERE emi_id NOT IN
(
SELECT emi_id FROM v_publish
)

UNION

SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, emi_id, perenimi, eesnimi, isanimi, sünd, surm, kirjed
FROM v_publish
WHERE emi_id NOT IN
(
SELECT emi_id FROM ohvrite_nimekiri_2018_02_13
)
;


CREATE OR REPLACE VIEW aruanne_põhjendamata_nimekujud AS
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'perenimi' AND x1.v = e.EmiPerenimi
WHERE e.EmiPerenimi IS NOT NULL
  AND e.perenimi != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'eesnimi' AND x1.v = e.EmiEesnimi
WHERE e.EmiEesnimi IS NOT NULL
  AND e.eesnimi != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'isanimi' AND x1.v = e.EmiIsanimi
WHERE e.EmiIsanimi IS NOT NULL
  AND e.isanimi != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'sünd' AND x1.v = e.EmiSünd
WHERE e.EmiSünd IS NOT NULL
  AND e.sünd != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'surm' AND x1.v = e.EmiSurm
WHERE e.EmiSurm IS NOT NULL
  AND e.surm != ''
  AND e.ref IS NULL
  AND x1.id IS NULL
;



CREATE OR REPLACE VIEW aruanne_allikata_nimekujud AS
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiPerenimi IS NOT NULL AND e.perenimi = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiEesnimi IS NOT NULL AND e.eesnimi = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiIsanimi IS NOT NULL AND e.isanimi = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiSünd IS NOT NULL AND e.sünd = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiSurm IS NOT NULL AND e.surm = ''
;

#!/bin/bash

echo 'pass "${MYSQL_PASS}"'


filename="/tmp/$(date +%Y%m%d_%H%M%S)_memoriaal_ee.csv"
mysql -umichelek -p'xxxxxxxx' repis<<EOFMYSQL
SELECT   nk.kirjekood AS id,
         nk.perenimi,
         nk.eesnimi,
         nk.isanimi,
         nk.emanimi,
         LEFT(nk.sünd,4) AS sünd,
         LEFT(nk.surm,4) AS surm,
         IF(ks.silt IS NULL, '', '!') AS kivi,
         IFNULL(REPLACE (
           group_concat( DISTINCT
             IF(a.prioriteetkirje = 0, NULL, concat(k.kirjekood,'#|', k.kirje,'#|', a.nimetus))
             ORDER BY a.prioriteetkirje DESC SEPARATOR ';_\n'
           ),
           '"',
           '\''
         ), '')           AS kirjed,
         IFNULL(REPLACE(
           group_concat( DISTINCT
             IF(kp.kirjekood IS NULL, NULL, concat_ws('#|',kp.kirjekood, kp.kirje, a.nimetus, kp.persoon))
             ORDER BY kp.kirjekood ASC SEPARATOR ';_\n'
           ),
           '"',
           '\''
         ), '')           AS pereseos
FROM repis.kirjed AS k
LEFT JOIN repis.allikad AS a ON a.kood = k.allikas
LEFT JOIN repis.kirjed AS kp ON kp.perekood <> '' AND kp.perekood = k.perekood
LEFT JOIN repis.kirjed AS nk ON nk.persoon = k.persoon AND nk.allikas = 'Persoon'
LEFT JOIN repis.v_kirjesildid AS ks ON ks.kirjekood = nk.persoon AND ks.silt = 'x - kivi' AND ks.deleted_at = '0000-00-00 00:00:00'
WHERE k.ekslikkanne = ''
AND k.puudulik = ''
AND k.peatatud = ''
AND nk.persoon IS NOT NULL
GROUP BY k.persoon
HAVING perenimi != ''
INTO OUTFILE '${filename}'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
EOFMYSQL

#!/bin/bash

filename="/tmp/$(date +%Y%m%d_%H%M%S)_memoriaal_ee.csv"

mysql -umichelek -p'xxxxxxxx' aruanded<<EOFMYSQL
SELECT * FROM aruanded.memoriaal_ee
INTO OUTFILE '${filename}'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
EOFMYSQL

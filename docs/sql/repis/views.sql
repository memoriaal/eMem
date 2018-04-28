CREATE OR REPLACE VIEW repis.a_persoonid
AS
  SELECT  nk.kirjekood       AS id,
          substring_index( substring_index( group_concat(
            IF(k.perenimi = '' OR a.prioriteetperenimi = 0,
              '', ucase(k.perenimi)
            ) ORDER BY a.prioriteetperenimi DESC SEPARATOR ';'
          ),';',1 ),';',-1 ) AS perenimi,
          substring_index( substring_index( group_concat(
            IF(k.eesnimi = '' OR a.prioriteeteesnimi = 0,
              '', ucase(k.eesnimi)
            ) ORDER BY a.prioriteeteesnimi  DESC SEPARATOR ';'
          ),';',1 ),';',-1 ) AS eesnimi,
          substring_index( substring_index( group_concat(
            IF(k.isanimi = '' OR a.prioriteetisanimi = 0,
              '', ucase(k.isanimi)
            ) ORDER BY a.prioriteetisanimi  DESC SEPARATOR ';'
          ),';',1 ),';',-1 ) AS isanimi,
          substring_index( substring_index( group_concat(
            IF(k.emanimi = '' OR a.prioriteetemanimi = 0,
              '', ucase(k.emanimi)
            ) ORDER BY a.prioriteetemanimi  DESC SEPARATOR ';'
          ),';',1 ),';',-1 ) AS emanimi,
          substring_index( substring_index( group_concat(
            IF(k.sünd = '' OR a.prioriteetsünd = 0,
              '', k.sünd
            ) ORDER BY a.prioriteetsünd     DESC SEPARATOR ';'
          ),';',1 ),';',-1 ) AS sünd,
          substring_index( substring_index( group_concat(
            IF(k.surm = '' OR a.prioriteetsurm = 0,
              '', k.surm
            ) ORDER BY a.prioriteetsurm     DESC SEPARATOR ';'
          ),';',1 ),';',-1 ) AS surm,
          ifnull( REPLACE( group_concat(
            DISTINCT
            IF(
              a.prioriteetkirje = 0,
              NULL,
              concat(k.kirjekood,'#|',k.kirje,'#|',a.nimetus)
            )
            ORDER BY a.prioriteetkirje DESC
            SEPARATOR ';\n'
          ),'"','\''),'')    AS kirjed
  FROM  kirjed k
        RIGHT JOIN kirjed nk ON nk.persoon = k.persoon
                            AND nk.allikas = 'Nimekujud'
        LEFT JOIN allikad a ON a.kood = k.allikas
 WHERE  k.ekslikkanne = ''
   AND  k.puudulik = ''
   AND  k.peatatud = ''
   AND  nk.persoon IS NOT NULL
 GROUP BY nk.persoon;

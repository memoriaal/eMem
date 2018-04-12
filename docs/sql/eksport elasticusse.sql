CREATE or replace view `web_export`
AS
  SELECT   nk.isikukood AS `id`,
           substring_index(substring_index(group_concat(
             IF(k.perenimi = '' OR a.prioriteetperenimi = 0, '', ucase(k.perenimi)) ORDER BY a.prioriteetperenimi DESC SEPARATOR ';'
           ),';',1),';',-1) AS `perenimi`,
           substring_index(substring_index(group_concat(
             IF(k.eesnimi = '' OR a.prioriteeteesnimi = 0, '', REPLACE(ucase(k.eesnimi),'ALEKSANDR','ALEKSANDER')) ORDER BY a.prioriteeteesnimi DESC SEPARATOR ';'
           ),';',1),';',-1) AS `eesnimi`,
           substring_index(substring_index(group_concat(
             IF(k.isanimi = '' OR a.prioriteetisanimi = 0, '', ucase(k.isanimi)) ORDER BY a.prioriteetisanimi DESC SEPARATOR ';'
           ),';',1),';',-1) AS `isanimi`,
           substring_index(substring_index(group_concat(
             IF(k.emanimi = '' OR a.prioriteetemanimi = 0, '', ucase(k.emanimi)) ORDER BY a.prioriteetemanimi DESC SEPARATOR ';'
           ),';',1),';',-1) AS `emanimi`,
           substring_index(substring_index(group_concat(
             IF(k.sünd = '' OR a.prioriteetsünd = 0, '', LEFT(k.sünd,4)) ORDER BY a.prioriteetsünd DESC SEPARATOR ';'
           ),';',1),';',-1) AS `sünd`,
           substring_index(substring_index(group_concat(
             IF(k.surm = '' OR a.prioriteetsurm = 0, '', LEFT(k.surm,4)) ORDER BY a.prioriteetsurm DESC SEPARATOR ';'
           ),';',1),';',-1) AS `surm`,
           k.kivi           AS `kivi`,
           IFNULL(REPLACE (
             group_concat( DISTINCT
               IF(a.prioriteetkirje = 0, NULL, concat(k.isikukood,'#|',k.kirje,'#|',a.nimetus))
               ORDER BY a.prioriteetkirje DESC SEPARATOR ';\n'
             ),
             '"',
             '\''
           ), '')           AS `kirjed`,
           IFNULL(REPLACE(
             group_concat(
               IF(kp.isikukood IS NULL, NULL, concat_ws('#|',kp.isikukood, kp.kirje, ''))
               ORDER BY kp.isikukood ASC SEPARATOR ';\n'
             ),
             '"',
             '\''
           ), '')           AS `pereseos`
FROM kirjed AS `k`
  LEFT JOIN allikad AS `a` ON a.kood = k.allikas
  LEFT JOIN kirjed AS `kp` ON kp.perekood <> ''
                         AND kp.perekood = k.perekood
  LEFT JOIN kirjed AS `nk` ON nk.emi_id = k.emi_id AND nk.allikas = 'Nimekujud'
WHERE k.ekslikkanne = ''
  AND k.puudulik = ''
  AND k.peatatud = ''
  AND nk.isikukood IS NOT NULL
GROUP BY k.emi_id;



CREATE or replace VIEW `es_export`
AS SELECT
    `i`.`id` AS `id`,
    `i`.`sünniaasta` AS `sünniaasta`,
    `i`.`perenimi` AS `perenimi`,
    `i`.`eesnimi` AS `eesnimi`,
    `i`.`isanimi` AS `isanimi`,
    `inf`.`kasHukkunud` AS `kasHukkunud`,
    `inf`.`allikad` AS `allikad`
FROM (`isikud` `i` left join `isikuinfo` `inf` on((`inf`.`id` = `i`.`id`))) where isnull(`i`.`baaskirje`);


-- alternatiiv
CREATE or replace VIEW `es_export`
AS SELECT
    `i`.`id` AS `id`,
    `i`.`sünniaasta` AS `sünniaasta`,
    `i`.`perenimi` AS `perenimi`,
    `i`.`eesnimi` AS `eesnimi`,
    `i`.`isanimi` AS `isanimi`,
    `inf`.`kasHukkunud` AS `kasHukkunud`,
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      `inf`.`allikad`, 'r1:',     '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_1.pdf@>Memento @POLIITILISED ARRETEERIMISED EESTIS 1940-1988@</a> '
                    ),                 'r2:',     '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_2.pdf@>Memento @NÕUKOGUDE OKUPATSIOONIVÕIMU POLIITILISED ARRETEERIMISED EESTIS 1940-1988@</a> '
                  ),                   'r3:',     '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_3.pdf@>Memento @NÕUKOGUDE OKUPATSIOONIVÕIMU POLIITILISED ARRETEERIMISED EESTIS 1940-1988@</a> '
                ),                     'r4:',     '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_4.pdf@>Memento @KÜÜDITAMINE EESTIST VENEMAALE MÄRTSIKÜÜDITAMINE 1949 1. osa@</a> '
              ),                       'r5:',     '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_5.pdf@>Memento @KÜÜDITAMINE EESTIST VENEMAALE MÄRTSIKÜÜDITAMINE 1949 2. osa@</a> '
            ),                         'r6:',     '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_6.pdf@>Memento @KÜÜDITAMINE  EESTIST VENEMAALE JUUNIKÜÜDITAMINE 1941 & KÜÜDITAMISED 1940-1953@</a> '
          ),                           'r7:',     '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_7.pdf@>Memento @NÕUKOGUDE OKUPATSIOONIVÕIMUDE KURITEOD EESTIS KÜÜDITATUD, ARRETEERITUD, TAPETUD 1940-1990 NIMEDE KOONDREGISTER R1 – R6@</a> '
        ),                             'r81:',    '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_81.pdf@>Memento @KOMMUNISMI KURITEOD EESTIS, Lisanimestik 1940–1990, raamatute R1–R7 täiendamiseks@</a> '
      ),                               'r81_20:', '<a href=@http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_81_20.pdf@>Memento @KOMMUNISMI KURITEOD EESTIS, Lisanimestik 1940–1990, raamatute R1–R7 täiendamiseks@</a> '
    )
     AS `allikad`
FROM (`isikud` `i` left join `isikuinfo` `inf` on((`inf`.`id` = `i`.`id`))) where isnull(`i`.`baaskirje`);
